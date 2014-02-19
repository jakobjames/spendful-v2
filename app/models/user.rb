class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :email, :password, :name, :address_line1, :address_line2, :address_city, :address_zip, :country
  
  has_many :budgets, :dependent => :destroy, :order => 'budgets.updated_at desc'
  has_many :feedbacks, :dependent => :destroy
  has_many :subscriptions, :dependent => :destroy

  validates :email, :presence => true, :uniqueness => true, :email => true
  validates :password, :presence => true, :on => :create

  before_validation :before_validation_process
  before_save :ensure_password_digest, :ensure_uuid

  def current_subscription
    return if self.subscriptions.empty?
    self.subscriptions.find { |subscription| subscription.active? || subscription.in_grace_period? }
  end

  def premium?
    self.current_subscription.present?
  end
  
  def trial_days_left
    return -1 if self.premium?
    launch_date = Constants::Subscriptions::LAUNCH_DATE
    start_date = self.created_at.to_date
    start_date = launch_date if start_date < launch_date
    end_date = start_date + Constants::Subscriptions::TRIAL_PERIOD.days
    if end_date < Date.today
      return 0
    else
      return (end_date - Date.today).to_i
    end
  end

  def trial?
    # self.trial_days_left > 0
    true
  end

  def User.authenticate(email, password)
    user = find_by_email(email.downcase)
    
    return nil, Constants::Users::UNKNOWN_EMAIL unless user
    
    # have a user, does the password match?
    return (BCrypt::Password.new(user.password_digest) == password.downcase) ? [user, Constants::Users::LOGIN_SUCCESSFUL] : [nil, Constants::Users::WRONG_PASSWORD]
  end
  
  def update_personal(attributes)
    attributes.each{|attr| attributes.delete(attr) unless read_attribute(attr).nil?}
    self.update_attributes(attributes)
  end

  protected

  def before_validation_process
    ensure_email
    ensure_password
  end

  def ensure_password_digest
    # since password is implemented using attr_accessor, password.present? should
    # be true only when it has been changed through user interaction.
    self.password_digest = BCrypt::Password.create(password) if password.present?
  end

  def ensure_uuid
    # since password is implemented using attr_accessor, password.present? should
    # be true only when it has been changed through user interaction, and we want
    # to change the uuid whenever the password changes
    self.uuid = UUIDTools::UUID.random_create.to_s if self.uuid.nil? || password.present?

    # make sure uuid is not already used
    while User.exists?(:uuid => self.uuid)
      self.uuid = UUIDTools::UUID.random_create.to_s
    end
  end

  private

  def ensure_email
    self.email = self.email.downcase if self.email
  end

  def ensure_password
    self.password = self.password.downcase if self.password
  end
end
