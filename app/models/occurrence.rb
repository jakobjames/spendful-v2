class Occurrence
  include ActiveModel::Model
  include ActiveModel::Dirty

  ACCESSIBLE_ATTRIBUTES = [:date, :name, :schedule, :starts_on, :ends_on, :amount]

  attr_reader :date, :category, :name, :schedule, :starts_on, :ends_on, :amount
  attr_accessor :item

  # dirty tracking
  define_attribute_methods ACCESSIBLE_ATTRIBUTES

  def initialize(attributes = {})
    super attributes

    @category = @item.category
    @name = @item.name
    @starts_on = @item.starts_on
    @ends_on = @item.ends_on
    @schedule = @item.schedule
    @amount = @item.amount

    # since these objects are not persisted, we don't want
    # a newly created (built) instance appearing to be dirty
    reset_dirty_tracking
  end

  def item_id
    @item.id
  end

  def date=(date)
    return if date == @date
    date_will_change!
    @date = date
  end

  def name=(name)
    return if name == @name
    name_will_change!
    @name = name
  end

  def schedule=(schedule)
    return if schedule == @schedule
    schedule_will_change!
    @schedule = schedule
  end

  def starts_on=(starts_on)
    return if starts_on == @starts_on
    starts_on_will_change!
    @starts_on = starts_on
  end

  def ends_on=(ends_on)
    return if ends_on == @ends_on
    ends_on_will_change!
    @ends_on = ends_on
  end

  def amount=(amount)
    return if amount == @amount
    amount_will_change!
    @amount = amount
  end

  def first?
    self.ordinal == 1
  end

  def index
    # use *_was in case values are being changed
    starting = (self.starts_on_was || @starts_on).to_time
    ending = (self.date_was || @date).to_time
    @item.ice_cube_schedule.occurrences_between(starting, ending).size - 1
  end

  def ordinal
    self.index + 1
  end

  def transactions
    transactions_by_occurrence(@date)
  end
  
  def actual
    total = 0
    self.transactions.each { |t| total += t.amount }
    total
  end

  def update_attribute(attribute, value)
    self.update_attributes attribute => value
  end

  def update_attributes(attributes = {})
    return unless attributes.is_a?(Hash)

    ACCESSIBLE_ATTRIBUTES.each do |attribute|
      self.send "#{attribute}=", attributes[attribute] if attributes.has_key?(attribute)
    end

    self.save
  end # def update_attributes

  def save
    return true unless self.changed?

    handle_date_change if self.date_changed?
    handle_name_change if self.name_changed?
    handle_schedule_change if self.schedule_changed?
    handle_starts_on_change if self.starts_on_changed?
    handle_ends_on_change if self.ends_on_changed?
    handle_amount_change if self.amount_changed?

    successful = create_or_update_item

    reset_dirty_tracking

    successful
  end # def save

  def destroy
    if @item.once?
      @item.destroy
    else
      self.transactions.each { |txn| txn.orphan! }

      if self.first?
        second_occurrence = @item.occurrences.ordinal(2)
        @item.starts_on = second_occurrence.date
      else
        @item.ice_cube_schedule.add_exception_time @date.to_time
      end

      @item.save
    end # item.once? is false
  end # def destroy

  def valid?
    self.errors.empty?
  end

  private

  def reset_dirty_tracking
    @changed_attributes.clear
  end

  def handle_date_change
    # if an occurrence already exists on the new date, fail
    if @item.occurrences.exists?(@date)
      @date = self.date_was
      self.errors.add :date, 'cannot be changed to a date on which an occurrence already exists'
      return
    end

    # is the schedule is once
    if @schedule == 'once'
      @item.starts_on = @date
    else
      second_occurrence = @item.occurrences.ordinal(2)

      ends_on = @ends_on || @date

      if (@starts_on..ends_on).include?(@date) && @date > second_occurrence.date
        # if the new date is between item.starts_on and item.ends_on and it's after the second occurrence
        # => do not create a new item
        # => add recurrence_time to ice_cube_schedule for new occurrence date
        @item.ice_cube_schedule.add_recurrence_time @date.to_time
        # this instance var is an ugly hack, but ice_cube methods don't trigger dirty tracking on the item
        @item_needs_saved = true
      else
        # if the new date is not between item.starts_on and item.ends_on or if it's before the second occurrence

        # => create a new once item for the new date
        duplicate_item :schedule => 'once', :starts_on => @date
      end

      if self.first?
        # if it is the first occurrence:
        # => change the item.starts_on to the second occurrence
        @item.starts_on = second_occurrence.date
      else
        # if it is not the first occurrence
        # => add an exclusion to the original item's ice_cube_schedule
        @item.ice_cube_schedule.add_exception_time self.date_was.to_time
        # this instance var is an ugly hack, but ice_cube methods don't trigger dirty tracking on the item
        @item_needs_saved = true
      end
    end # schedule is not once and it's not the first occurrence
  end # def handle_date_change

  def handle_name_change
    @item.name = @name
  end # def handle_name_change

  def handle_schedule_change
    # if transactions exist *after* this occurrence, don't change the schedule
    if @item.transactions.normal.any? { |txn| txn.occurrence > @date }
      @schedule = self.schedule_was
      self.errors.add :schedule, 'cannot be changed when transactions exist after this occurrence'
      return
    end

    if self.schedule_was == 'once' || self.first?
      @item.schedule = @schedule
    else
      # create the new item with the updated schedule and starts_on
      duplicate_item :schedule => @schedule, :starts_on => @date
      # end the previous item on the occurrence before this one
      previous_occurrence = @item.occurrences.ordinal(self.ordinal - 1)
      # if the previous occurrence is the first one, we need to change the existing
      # item's schedule to 'once' because ends_on will == starts_on. otherwise, just change ends_on
      if previous_occurrence.first?
        @item.schedule = 'once'
      else
        @item.ends_on = previous_occurrence.date
      end
    end
  end # handle_schedule_change

  def handle_starts_on_change
		if @starts_on.empty?
      @starts_on = self.starts_on_was
      self.errors.add :starts_on, 'must be a valid date'
			return
		else
			@starts_on = Date.parse(@starts_on)
		end
    if @schedule != 'once'
      # if any normal transactions exist, don't change the starts_on
      if @item.transactions.normal.any?
        @starts_on = self.starts_on_was
        self.errors.add :starts_on, 'cannot be changed when transactions exist'
        return
      end
    end

    @item.starts_on = @starts_on
    self.date = @starts_on if @schedule == 'once' # to force txn.occurrence to get changed
    @item.schedule = 'once' if @starts_on == @ends_on
  end # def handle_starts_on_change

  def handle_ends_on_change
		if @ends_on.empty?
			@item.ends_on = nil
			return
		else
			@ends_on = Date.parse(@ends_on)
		end
    # if normal transactions exist *after* the new date, don't change it
    if @item.transactions.normal.any? { |txn| txn.occurrence > @ends_on }
      @ends_on = self.ends_on_was
      self.errors.add :ends_on, 'cannot be changed when transactions exist after the new date'
      return
    end

    @item.ends_on = @ends_on
    @item.schedule = 'once' if @ends_on == @starts_on
  end # def handle_ends_on_change

  def handle_amount_change
    # if normal transactions exist *after* this occurrence, don't change the amount
    if @item.transactions.normal.any? { |txn| txn.occurrence > @date }
      @amount = self.amount_was
      self.errors.add :amount, 'cannot be changed when transactions exist after this occurrence'
      return
    end

    # is the schedule once or is this the first occurrence of the schedule?
    if @schedule == 'once' || self.first?
      @item.amount = @amount
    else
      # create the new item with the updated starts_on and amount
      duplicate_item :starts_on => @date, :amount => @amount
      # end the previous item on the occurrence before this one
      previous_occurrence = @item.occurrences.ordinal(self.ordinal - 1)
      # if the previous occurrence is the first one, we need to change the existing
      # item's schedule to 'once' because ends_on will == starts_on. otherwise, just change ends_on
      if previous_occurrence.first?
        @item.schedule = 'once'
      else
        @item.ends_on = previous_occurrence.date
      end
    end
  end # def handle_amount_change

  def create_or_update_item
    return false if self.errors.any?

    # consider the scenario of a once item that has a transaction on the only occurrence. If we try to change
    # item.starts_on to a date *after* the original, it will fail because a txn will exist before the new date.
    # if we update the txn first, it will be okay. notice that the txn is updated using update_attribute, which
    # does not invoke validations. this is good because there is a validation that makes sure txn.occurrence
    # is a valid occurrence of the item. If saving either @item or @new_item fails for some reason, the txn will
    # be invalid, and the transaction will rollback the txn changes for us.

    ActiveRecord::Base.transaction do
      if self.date_changed? && !@new_item
        # if the occurrence date changed and no new item is being created, we need to change txn.occurrence of
        # any transactions tied to the single occurrence
        transactions_by_occurrence(self.date_was).each { |txn| txn.update_attribute :occurrence, @date }
      end

      # Save @new_item first because there could be txns that need to be moved to it. If the txns aren't moved
      # first, validation errors on the original item may result. An example is when the first occurrence of the
      # original item is getting split off into a new item and there is a txn tied to it. If the txn does not
      # get moved first, the original item's starts_on will be advanced there will be a txn with an earlier date,
      # and starts_on can't be changed to a date earlier than an existing transaction.
      if @new_item
        unless @new_item.save
          duplicate_errors!(@new_item)
          raise ActiveRecord::Rollback
        end

        # move transactions for this occurrence to the new item and
        # make sure transaction.occurrence is set correctly (in case @date changed also)
        date = self.date_was || @date
        transactions_by_occurrence(date).each { |txn| txn.update_attributes :item_id => @new_item.id, :occurrence => @date }

        # if the item amount changed, we also have to move transactions for later occurrences to the new item
        # (but there is no reason to adjust the occurrences of those transactions since they belong to occurrences
        # other than this one)
        if self.amount_changed?
          @item.transactions.where('occurrence > :date', :date => @date).each { |txn| txn.update_attributes :item_id => @new_item.id }
        end
      end # not @new_item

      if @item.changed? || @item_needs_saved
        unless @item.save
          duplicate_errors!(@item)
          raise ActiveRecord::Rollback
        end
      end

      # set the occurrence's item to the new item
      @item = @new_item if @new_item
    end # ActiveRecord::Base.transaction

    true
  end # def create_or_update_item

  def transactions_by_occurrence(date)
    @item.transactions.where(:occurrence => date).order(:date)
  end

  def duplicate_item(overrides = {})
    attributes = {
      :budget_id => @item.budget_id,
      :category => @item.category,
      :name => @item.name,
      :schedule => @item.schedule,
      :starts_on => @item.starts_on,
      :ends_on => @item.ends_on,
      :amount => @item.amount
    }.merge(overrides)

    @new_item = Item.new attributes
  end # duplicate_item

  def duplicate_errors!(item)
    item.errors.each do |attribute, error|
      self.errors.add attribute, error
    end
  end # duplicate_errors
end
