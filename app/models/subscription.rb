class Subscription < ActiveRecord::Base

  attr_accessible :user_id, :reference, :plan, :started_on, :expires_on, :cancelled_on, :card_type, :card_last4, :card_name

  belongs_to :user

  validate :validation_process

  def active?
    grace_period = Constants::Subscriptions::GRACE_PERIOD
    self.expires_on > (Date.today + grace_period) && self.cancelled_on.nil?
  end

  def in_grace_period?
    grace_period = Constants::Subscriptions::GRACE_PERIOD
    self.expires_on > Date.today && self.expires_on < (Date.today + grace_period) && self.cancelled_on.nil?
  end

  def expired?
    grace_period = Constants::Subscriptions::GRACE_PERIOD
    self.expires_on < (Date.today + grace_period) || self.cancelled_on.present?
  end

  def cancelled?
    self.cancelled_on.present?
  end

  def status
    return Constants::Subscriptions::STATUS_IN_GRACE_PERIOD if self.in_grace_period?
    return Constants::Subscriptions::STATUS_EXPIRED if self.expired?
    return Constants::Subscriptions::STATUS_CANCELLED if self.cancelled?
    Constants::Subscriptions::STATUS_ACTIVE
  end # def status

  protected

  def validation_process
    validate_started_on
    validate_expires_on
    validate_cancelled_on
    validate_current_subscription
  end

  private

  def validate_started_on
    return unless self.started_on
    self.errors.add :started_on, 'cannot be in the future' if self.started_on > Date.today
  end

  def validate_expires_on
    return unless self.started_on && self.expires_on
    self.errors.add :expires_on, 'must be after started on' unless self.expires_on > self.started_on
  end

  def validate_cancelled_on
    return unless self.started_on && self.cancelled_on
    self.errors.add :cancelled_on, 'cannot be before started on' if self.cancelled_on < self.started_on
  end

  def validate_current_subscription
    return if self.expired? || self.cancelled?

    other_subscriptions = self.user.subscriptions - [self]
    if other_subscriptions.any? { |subscription| subscription.active? }
      self.errors.add :base, Constants::Subscriptions::ALREADY_CURRENT_SUBSCRIPTION_ERROR
    end
  end
end
