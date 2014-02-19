class Transaction < ActiveRecord::Base
  attr_accessible :budget_id, :item_id, :category, :date, :occurrence, :amount, :description

  belongs_to :budget
  belongs_to :item

  validates :budget_id, :presence => true
  validates :amount, :presence => true, :numericality => { :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 2147483647 }
  validates :category, :presence => true, :inclusion => Constants::Items::CATEGORIES, :unless => Proc.new { |record| record.item_id }
  validates :date, :presence => true

  validate :occurrence_valid

  before_validation :ensure_budget, :ensure_amount
  before_save :ensure_occurrence

  scope :income, where(:category => 'income')
  scope :expense, where(:category => 'expense')
  scope :normal, where('transactions.item_id is not null and transactions.occurrence is not null')
  scope :misc, where('transactions.item_id is null or transactions.occurrence is null')
  scope :orphan, where('transactions.item_id is not null and transactions.occurrence is null')
  scope :between, lambda { |starting, ending| where('transactions.date between :starting and :ending', {:starting => starting, :ending => ending}) }
  scope :up_to, lambda { |ending| where('transactions.date <= :ending', {:ending => ending}) }

  def description
    self.read_attribute(:description).present? ? self.read_attribute(:description) : (self.orphan? ? self.item.name : Constants::Transactions::NO_DESCRIPTION)
  end

  def income?
    (self.item ? self.item.category : self.category) == 'income'
  end

  def expense?
    (self.item ? self.item.category : self.category) == 'expense'
  end

  def misc?
    self.item_id.blank?
  end

  def orphan?
    self.occurrence.blank? && !self.misc?
  end

  def normal?
    !(self.misc? || self.orphan?)
  end

  def orphan!
    self.update_attribute :occurrence, nil
  end

  def misc!
    self.update_attribute :item_id, nil
  end

  protected

  def occurrence_valid
    return unless self.item && self.occurrence
    self.errors.add(:occurrence, 'must be one of the item occurrences') unless self.item.occurrences.exists?(self.occurrence)
  end

  def ensure_budget
    return if self.budget
    self.budget_id = self.item.budget_id if self.item
  end

  def ensure_amount
    return unless self.amount
    self.amount = self.amount.floor
  end
  
  def ensure_occurrence
    self.occurrence = nil unless self.item_id
  end
end
