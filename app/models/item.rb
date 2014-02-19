class Item < ActiveRecord::Base
  attr_accessible :budget_id, :category, :name, :amount, :schedule, :starts_on, :ends_on

  serialize :schedule_details, Hash

  belongs_to :budget
  has_many :transactions

  validates :budget_id, :presence => true
  validates :category, :presence => true, :inclusion => { :in => Constants::Items::CATEGORIES }
  validates :name, :presence => true, :uniqueness => { :scope => [:budget_id, :starts_on] }
  validates :amount, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 2147483647 }
  validates :schedule, :presence => true, :inclusion => { :in => Constants::Items::SCHEDULES }
  validates :starts_on, :presence => true

  validate :validation_process

  before_validation :before_validation_process
  before_save :before_save_process
  before_destroy :before_destroy_process

  scope :income, where(:category => 'income')
  scope :expense, where(:category => 'expense')
  scope :between, lambda { |starting, ending| where('items.starts_on <= :ending and coalesce(items.ends_on, :ending) >= :starting', {:starting => starting, :ending => ending}) }

  Constants::Items::SCHEDULES.each do |schedule|
    define_method("#{schedule}?") do
      self.schedule == "#{schedule}"
    end
  end

  def ice_cube_schedule
    @ice_cube_schedule ||= IceCube::Schedule.from_hash(self.schedule_details)
  end

  def occurrences
    @occurrences ||= Occurrences.new self
  end

  def income?
    self.category == 'income'
  end

  def expense?
    self.category == 'expense'
  end

  protected

  def before_validation_process
    ensure_amount
    ensure_schedule
    ensure_ends_on
  end

  def validation_process
    validate_starts_on
    validate_ends_on
  end

  def before_save_process
    ensure_slug
    ensure_schedule_details
  end

  def before_destroy_process
    self.transactions.all.each { |txn| txn.misc! }
  end

  private

  def validate_starts_on
    return if self.new_record?
    return unless self.starts_on # already handled by standard presence validator
    # it can't be after the date of any transaction
    self.errors.add(:starts_on, 'cannot be after the date of an existing transaction') if self.transactions.normal.any? { |txn| txn.occurrence < self.starts_on }
  end

  def validate_ends_on
    return unless self.starts_on && self.ends_on
    self.errors.add(:ends_on, 'must be after starts on') unless self.ends_on > self.starts_on
    self.errors.add(:ends_on, 'cannot be before the date of an existing transaction') if self.transactions.any? { |txn| txn.date > self.ends_on }
  end

  def ensure_schedule
    self.schedule ||= 'once'
  end

  def ensure_ends_on
    self.ends_on = nil if self.once?
  end

  def ensure_amount
    return unless self.amount
    self.amount = self.amount.floor
  end

  def ensure_slug
    if self.name_changed?
      self.slug = self.name.parameterize

      query = "
        select count(*)
        from items
        where budget_id = #{self.budget_id}
          and slug ~* '^#{self.slug}(?:-[0-9]+)?$'
      "

      counter = self.class.connection.select_value(query).to_i
      self.slug += "-#{counter + 1}" if counter > 0
    end
  end

  def ensure_schedule_details
    if self.schedule_changed?
      @ice_cube_schedule = IceCube::Schedule.new
    else
      @ice_cube_schedule ||= IceCube::Schedule.new
    end

    start_time = self.starts_on.to_time.beginning_of_day
    end_time = self.ends_on.to_time.end_of_day rescue nil
    @ice_cube_schedule.start_time = start_time
    @ice_cube_schedule.end_time = end_time

    if self.new_record? || self.schedule_changed?
      case self.schedule
        when 'once'
          @ice_cube_schedule.add_recurrence_time start_time
        when 'weekly'
          @ice_cube_schedule.add_recurrence_rule IceCube::Rule.weekly
        when 'fortnightly'
          @ice_cube_schedule.add_recurrence_rule IceCube::Rule.weekly(2)
        when 'monthly'
          if start_time.day == start_time.end_of_month.day
            # last day of the month
            @ice_cube_schedule.add_recurrence_rule IceCube::Rule.monthly.day_of_month(-1)
          else
            @ice_cube_schedule.add_recurrence_rule IceCube::Rule.monthly.day_of_month(start_time.day)
          end

          if start_time.day > 28
            @ice_cube_schedule.add_recurrence_rule IceCube::Rule.yearly.month_of_year(:february).day_of_month(-1)
          end
        when 'yearly'
          @ice_cube_schedule.add_recurrence_rule IceCube::Rule.yearly
      end
    end

    unless self.new_record?
      # This is separated from the above conditional because of wanting share the code to configure
      # the ice_cube_schedule when the item is new *and* when the schedule changed on an existing item
      if self.starts_on_changed?
        @ice_cube_schedule.remove_recurrence_time self.starts_on_was.to_time
        @ice_cube_schedule.add_recurrence_time self.starts_on.to_time
      end
    end

    self.schedule_details = @ice_cube_schedule.to_hash
  end # def ensure_schedule_details
end
