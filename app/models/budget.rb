class Budget < ActiveRecord::Base
  attr_accessible :user_id, :name, :currency, :initial_balance
	attr_protected :slug

  belongs_to :user

  has_many :items, :dependent => :destroy
  has_many :transactions, :dependent => :destroy
  
  validates :name, :presence => true, :uniqueness => { :scope => :user_id }
  validates :initial_balance, :presence => true, :numericality => { :only_integer => true, :less_than_or_equal_to => 2147483647 }

  before_validation :ensure_initial_balance
  before_save :ensure_slug
 
  def to_param
    self.slug
  end

  def beginning
    @beginning ||= self.created_at.to_date.beginning_of_month
  end

  def occurrences(options = {})
    options[:starting] ||= Date.today.beginning_of_month
    options[:ending] ||= Date.today.end_of_month

    occurrences = []

    # options[:category] should be 'income', 'expense', or nil
    items = options[:category] ? self.items.send(options[:category]) : self.items

    items.each do |item|
      item_occurrences = item.occurrences.between options[:starting], options[:ending]
      occurrences += item_occurrences
    end

    occurrences.sort do |a, b|
      (a.date <=> b.date).nonzero? || (a.name <=> b.name)
    end
  end # def occurrences
  
  def misc_transactions(options = {})
    options[:starting] ||= Date.today.beginning_of_month
    options[:ending] ||= Date.today.end_of_month
    
    transactions = []

    # options[:category] should be 'income', 'expense', or nil
    all_transactions = options[:category] ? self.transactions.send(options[:category]) : self.transactions
    all_transactions = all_transactions.where("date > ?", options[:starting]).where("date < ?", options[:ending])
    
    all_transactions.each do |transaction|
      transactions << transaction if transaction.misc? || transaction.orphan?
    end
    
    transactions
  end # def transactions

  def balance(as_of)
    totals = { 'income' => 0, 'expense' => 0 }
    today = Date.today

    self.transactions.up_to([as_of, today].min).each do |transaction|
      totals[transaction.category] += transaction.amount
    end

    if as_of > today
      beginning_of_this_month = today.beginning_of_month
      tomorrow = today + 1.day

      self.occurrences(:starting => beginning_of_this_month, :ending => as_of).each do |occurrence|
        # txns up to today have already been accounted for in the first calculation of the method
        txns_accounted_for = 0
        txns_total = 0

        occurrence.transactions.up_to(as_of).each do |txn|
          txns_total += txn.amount
          txns_accounted_for += txn.amount if txn.date <= today  
        end

        totals[occurrence.category] += ([occurrence.amount, txns_total].max - txns_accounted_for)
      end # self.occurrences(:starting => beginning_of_this_month, :ending => as_of).each

      # when there is an occurrence outside the date range with a transaction inside the date range, we will miss the txn
      # in the previous loop because we are looking for occurrences within the date range. The code below queries for transactions
      # that have txn.date within the range *and* txn.occurrence without the range. This will allow us to include late transactions
      # (occurrence before date range) and early transactions (occurrence after date range). Use tomorrow because txns with date up to
      # today have already been counted
      conditions = ['transactions.date between :tomorrow and :as_of and transactions.occurrence not between :tomorrow and :as_of', {:tomorrow => tomorrow, :as_of => as_of}]
      self.transactions.normal.where(conditions).includes(:item).each { |txn| totals[txn.category] += txn.amount }
      
      # misc/orphan transactions .. use tomorrow because those up to today have already been taken care of
      self.transactions.misc.between(tomorrow, as_of).each { |txn| totals[txn.category] += txn.amount }
    end # as_of > today

    self.initial_balance + totals['income'] - totals['expense']
  end # balance

  protected

  def ensure_initial_balance
    return unless self.initial_balance
    self.initial_balance = self.initial_balance.floor
  end

  def ensure_slug
    self.slug = self.name.parameterize if self.name_changed?
  end

end
