require 'model_helper'

describe Budget do
  it 'should belong to user' do
    user = Factory.create :user
    budget = Factory.create :budget, :user => user
    budget.user.should == user
  end

  it 'should have many items' do
    budget = Factory.create :budget
    item = Factory.create :item, :budget => budget
    budget.items.should == [item]
  end

  it 'should destroy items when self is destroyed' do
    item = Factory.create :item
    item.budget.destroy
    Item.count.should == 0
  end

  it 'should have many transactions' do
    budget = Factory.create :budget
    transaction = Factory.create :transaction, :budget => budget, :item => nil
    budget.transactions.should == [transaction]
  end

  it 'should destroy transactions when self is destroyed' do
    budget = Factory.create :budget
    transaction = Factory.create :transaction, :budget => budget, :item => nil
    budget.destroy
    Transaction.count.should == 0
  end

  describe '#to_param' do
    it 'should return #slug' do
      budget = Factory.build :budget
      budget.to_param.should == budget.slug
    end
  end # describe '#to_param'

  describe 'name' do
    it 'should be required' do
      budget = Factory.build :budget, :name => nil
      budget.should have_at_least(1).error_on(:name)
    end

    it 'should be unique by user' do
      budget_1 = Factory.create :budget
      budget_2 = Factory.build :budget, :user => budget_1.user, :name => budget_1.name
      budget_2.should have_at_least(1).error_on(:name)
    end

    it 'should be reusable by different users' do
      budget_1 = Factory.create :budget
      budget_2 = Factory.build :budget, :name => budget_1.name
      budget_2.should be_valid
    end
  end # describe 'name'

  describe 'slug' do
    it 'should be set automatically' do
      budget = Factory.create :budget
      budget.slug.should_not be_nil
    end

    it 'should be the name parameterized' do
      budget = Factory.create :budget
      budget.slug.should == budget.name.parameterize
    end

    it 'should change when the name changes' do
      budget = Factory.create :budget
      budget.update_attribute :name, budget.name.reverse
      budget.slug.should == budget.name.parameterize
    end
  end # describe 'slug'

  describe 'initial_balance' do
    it 'should be required' do
      budget = Factory.build :budget, :initial_balance => nil
      budget.should have_at_least(1).error_on(:initial_balance)
    end

    it 'should allow values <= 0' do
      budget = Factory.build :budget, :initial_balance => 0
      budget.should have(:no).errors_on(:initial_balance)

      budget = Factory.build :budget, :initial_balance => -1
      budget.should have(:no).errors_on(:initial_balance)
    end

    it 'should truncate decimal values' do
      budget = Factory.build :budget, :initial_balance => 123.45
      budget.should have(:no).errors_on(:initial_balance)
      budget.initial_balance.should == 123
    end
  end # describe 'initial_balance'

  describe '#beginning' do
    it 'should be the beginning of the month the budget was created' do
      budget = Factory.create :budget
      budget.beginning.should == budget.created_at.to_date.beginning_of_month
    end
  end # describe '#beginning'

  describe '#occurrences' do
    before(:each) do
      # going to use explicit dates to avoid flickering
      @starting = Date.parse('2012-06-01')
      @ending = @starting.end_of_month
      @budget = Factory.create :budget

      # occurrences 6-08 (1 in the month)
      Factory.create :item, :budget => @budget, :schedule => 'once', :name => 'Once Income Item', :starts_on => Date.parse('2012-06-08'), :category => 'income'

      # occurrences 6-29 (1 in the month)
      Factory.create :item, :budget => @budget, :schedule => 'once', :name => 'Once Expense Item', :starts_on => Date.parse('2012-06-29'), :category => 'expense'

      # occurrences 5-25, 6-1, 6-8, 6-15, 6-22, 6-29, 7-6 (5 in the month)
      Factory.create :item, :budget => @budget, :schedule => 'weekly', :name => 'Weekly Income Item', :starts_on => @starting - 1.week, :ends_on => @ending + 1.week, :category => 'income'

      # occurrences 5-27, 6-3, 6-10, 6-17, 6-24, 7-1, 7-8 (4 in the month)
      Factory.create :item, :budget => @budget, :schedule => 'weekly', :name => 'Weekly Expense Item', :starts_on => @starting - 1.week + 2.days, :ends_on => @ending + 1.week + 2.days, :category => 'expense'

      # occurrences 5-18, 6-1, 6-15, 6-29, 7-13 (3 in the month)
      Factory.create :item, :budget => @budget, :schedule => 'fortnightly', :name => 'Fortnightly Income Item', :starts_on => @starting - 2.week, :ends_on => @ending + 2.weeks, :category => 'income'

      # occurrences 5-20, 6-3, 6-17, 7-1, 7-15 (2 in the month)
      Factory.create :item, :budget => @budget, :schedule => 'fortnightly', :name => 'Fortnightly Expense Item', :starts_on => @starting - 2.week + 2.days, :ends_on => @ending + 2.weeks + 2.days, :category => 'expense'

      # occurrences 5-1, 6-1, 7-2 (1 in the month)
      Factory.create :item, :budget => @budget, :schedule => 'monthly', :name => 'Monthly Income Item', :starts_on => @starting - 1.month, :ends_on => @ending + 1.month, :category => 'income'

      # occurrences 5-3, 6-3, 7-3 (1 in the month)
      Factory.create :item, :budget => @budget, :schedule => 'monthly', :name => 'Monthly Expense Item', :starts_on => @starting - 1.month + 2.days, :ends_on => @ending + 1.month + 2.days, :category => 'expense'

      @june_1 = Date.parse('2012-06-01')
      @june_3 = Date.parse('2012-06-03')
      @june_8 = Date.parse('2012-06-08')
      @june_10 = Date.parse('2012-06-10')
      @june_15 = Date.parse('2012-06-15')
      @june_17 = Date.parse('2012-06-17')
      @june_22 = Date.parse('2012-06-22')
      @june_24 = Date.parse('2012-06-24')
      @june_29 = Date.parse('2012-06-29')
    end # before(:each)

    context 'when no starting/ending date is specified' do
      before(:each) do
        @another_budget = Factory.create :budget
        another_item = Factory.create :item, :budget => @another_budget
        @occurrences = mock Occurrences
        @occurrences.stub(:between).and_return([])
        another_item.stub(:occurrences).and_return(@occurrences)
        @another_budget.stub(:items).and_return([another_item])
      end

      it 'should use the beginning of the current month' do
        beginning_of_month = Date.today.beginning_of_month
        end_date = beginning_of_month + 40.days # to make sure it's not the end of the month
        @occurrences.should_receive(:between).with(beginning_of_month, end_date)
        @another_budget.occurrences :ending => end_date
      end

      it 'should use the end of the current month' do
        start_date = Date.today.beginning_of_month - 10.days # to make sure it's not the start of the month
        end_of_month = Date.today.end_of_month
        @occurrences.should_receive(:between).with(start_date, end_of_month)
        @another_budget.occurrences :starting => start_date
      end
    end # context 'when no starting/ending date is specified'

    context 'when no category is specified' do
      before(:each) do
        @occurrences = @budget.occurrences :starting => @starting, :ending => @ending
      end

      it 'should return all occurrences for the date range' do
        @occurrences.size.should == 18
      end

      it 'should not include occurrences in past months' do
        (@occurrences.any? { |occurrence| occurrence.date < @starting }).should_not be_true
      end

      it 'should not include occurrences in future months' do
        (@occurrences.any? { |occurrence| occurrence.date > @ending }).should_not be_true
      end

      it 'should order the occurrences by occurrence.date and item.name' do
        # 6-1
        @occurrences[0].date.should == @june_1
        @occurrences[1].date.should == @june_1
        @occurrences[2].date.should == @june_1
        @occurrences[0].name.should == 'Fortnightly Income Item'
        @occurrences[1].name.should == 'Monthly Income Item'
        @occurrences[2].name.should == 'Weekly Income Item'

        # 6-3
        @occurrences[3].date.should == @june_3
        @occurrences[4].date.should == @june_3
        @occurrences[5].date.should == @june_3
        @occurrences[3].name.should == 'Fortnightly Expense Item'
        @occurrences[4].name.should == 'Monthly Expense Item'
        @occurrences[5].name.should == 'Weekly Expense Item'

        # 6-8
        @occurrences[6].date.should == @june_8
        @occurrences[7].date.should == @june_8
        @occurrences[6].name.should == 'Once Income Item'
        @occurrences[7].name.should == 'Weekly Income Item'

        # 6-10
        @occurrences[8].date.should == @june_10
        @occurrences[8].name.should == 'Weekly Expense Item'

        # 6-15
        @occurrences[9].date.should == @june_15
        @occurrences[10].date.should == @june_15
        @occurrences[9].name.should == 'Fortnightly Income Item'
        @occurrences[10].name.should == 'Weekly Income Item'

        # 6-17
        @occurrences[11].date.should == @june_17
        @occurrences[12].date.should == @june_17
        @occurrences[11].name.should == 'Fortnightly Expense Item'
        @occurrences[12].name.should == 'Weekly Expense Item'

        # 6-22
        @occurrences[13].date.should == @june_22
        @occurrences[13].name.should == 'Weekly Income Item'

        # 6-24
        @occurrences[14].date.should == @june_24
        @occurrences[14].name.should == 'Weekly Expense Item'

        # 6-29
        @occurrences[15].date.should == @june_29
        @occurrences[16].date.should == @june_29
        @occurrences[17].date.should == @june_29
        @occurrences[15].name.should == 'Fortnightly Income Item'
        @occurrences[16].name.should == 'Once Expense Item'
        @occurrences[17].name.should == 'Weekly Income Item'
      end # it 'should order the occurrences by occurrence.date and item.name'
    end # context 'when no category specified'

    context 'when category is income' do
      before(:each) do
        @occurrences = @budget.occurrences :starting => @starting, :ending => @ending, :category => 'income'
      end

      it 'should return only income occurrences for the date range' do
        @occurrences.size.should == 10
        (@occurrences.any? { |occurrence| occurrence.category == 'expense' }).should_not be_true
      end

      it 'should order the occurrences by occurrence.date and item.name' do
        # 6-1
        @occurrences[0].date.should == @june_1
        @occurrences[1].date.should == @june_1
        @occurrences[2].date.should == @june_1
        @occurrences[0].name.should == 'Fortnightly Income Item'
        @occurrences[1].name.should == 'Monthly Income Item'
        @occurrences[2].name.should == 'Weekly Income Item'

        # 6-8
        @occurrences[3].date.should == @june_8
        @occurrences[4].date.should == @june_8
        @occurrences[3].name.should == 'Once Income Item'
        @occurrences[4].name.should == 'Weekly Income Item'

        # 6-15
        @occurrences[5].date.should == @june_15
        @occurrences[6].date.should == @june_15
        @occurrences[5].name.should == 'Fortnightly Income Item'
        @occurrences[6].name.should == 'Weekly Income Item'

        # 6-22
        @occurrences[7].date.should == @june_22
        @occurrences[7].name.should == 'Weekly Income Item'

        # 6-29
        @occurrences[8].date.should == @june_29
        @occurrences[9].date.should == @june_29
        @occurrences[8].name.should == 'Fortnightly Income Item'
        @occurrences[9].name.should == 'Weekly Income Item'
      end # it 'should order the occurrences by occurrence.date and item.name'
    end # context 'when category is income'

    context 'when category is expense' do
      before(:each) do
        @occurrences = @budget.occurrences :starting => @starting, :ending => @ending, :category => 'expense'
      end

      it 'should return only expense occurrences for the date range' do
        @occurrences.size.should == 8
        (@occurrences.any? { |occurrence| occurrence.category == 'income' }).should_not be_true
      end

      it 'should order the occurrences by occurrence.date and item.name' do
        # 6-3
        @occurrences[0].date.should == @june_3
        @occurrences[1].date.should == @june_3
        @occurrences[2].date.should == @june_3
        @occurrences[0].name.should == 'Fortnightly Expense Item'
        @occurrences[1].name.should == 'Monthly Expense Item'
        @occurrences[2].name.should == 'Weekly Expense Item'

        # 6-10
        @occurrences[3].date.should == @june_10
        @occurrences[3].name.should == 'Weekly Expense Item'

        # 6-17
        @occurrences[4].date.should == @june_17
        @occurrences[5].date.should == @june_17
        @occurrences[4].name.should == 'Fortnightly Expense Item'
        @occurrences[5].name.should == 'Weekly Expense Item'

        # 6-24
        @occurrences[6].date.should == @june_24
        @occurrences[6].name.should == 'Weekly Expense Item'

        # 6-29
        @occurrences[7].date.should == @june_29
        @occurrences[7].name.should == 'Once Expense Item'
      end # it 'should order the occurrences by occurrence.date and item.name'
    end # context 'when category is expense'
  end # describe '#occurrences'

  describe 'chaining misc and between transaction scopes together' do
    before(:each) do
      beginning_of_month = Date.today.beginning_of_month
      end_of_month = beginning_of_month.end_of_month

      budget_1 = Factory.create :budget
      budget_2 = Factory.create :budget

      item_1 = Factory.create :item, :budget => budget_1
      occurrence = item_1.occurrences.first
      txn_1 = Factory.create :transaction, :item => item_1, :occurrence => occurrence.date, :date => occurrence.date
      txn_2 = Factory.create :transaction, :budget => budget_1, :item => nil, :occurrence => nil, :date => beginning_of_month - 1.week
      @txn_3 = Factory.create :transaction, :budget => budget_1, :item => nil, :occurrence => nil, :date => beginning_of_month + 1.week
      txn_4 = Factory.create :transaction, :budget => budget_1, :item => nil, :occurrence => nil, :date => end_of_month + 1.week

      item_2 = Factory.create :item, :budget => budget_2
      occurrence = item_2.occurrences.first
      txn_5 = Factory.create :transaction, :item => item_2, :occurrence => occurrence.date, :date => occurrence.date
      txn_6 = Factory.create :transaction, :budget => budget_2, :item => nil, :occurrence => nil, :date => beginning_of_month - 1.week
      txn_7 = Factory.create :transaction, :budget => budget_2, :item => nil, :occurrence => nil, :date => beginning_of_month + 1.week
      txn_8 = Factory.create :transaction, :budget => budget_2, :item => nil, :occurrence => nil, :date => end_of_month + 1.week

      @misc_transactions = budget_1.transactions.misc.between beginning_of_month, end_of_month
    end

    it 'should return only misc txns between a date range' do
      @misc_transactions.size.should == 1
      @misc_transactions.first.id.should == @txn_3.id
    end
  end # describe 'chaining misc and between transaction scopes together'

  describe '#balance' do
    before(:each) do
      @today = Date.today
      @beginning_of_last_month = @today.beginning_of_month - 1.month
      # doing end_of_month + 1.month will not always get to the last day of the month. e.g., june 30 is end_of_month, but plus
      # one month is july 30, not july 31. june 1 + 2.months == august 1, minus 1.day == july 31 (end_of_month for july)
      @end_of_next_month = @today.beginning_of_month + 2.months - 1.day

      @budget = Factory.create :budget
      @income_item = Factory.create :item, :budget => @budget, :category => 'income', :schedule => 'weekly', :starts_on => @beginning_of_last_month, :ends_on => @end_of_next_month
      @income_occurrence = @income_item.occurrences.first
      @expense_item = Factory.create :item, :budget => @budget, :category => 'expense', :schedule => 'weekly', :starts_on => @beginning_of_last_month, :ends_on => @end_of_next_month
      @expense_occurrence = @expense_item.occurrences.first
    end

    it 'should start with initial_balance' do
      # notice there are no items or transactions
      @budget.balance(@today).should == @budget.initial_balance
    end

    it 'should exclude transactions from other budgets' do
      other_budget = Factory.create :budget
      other_txn = Factory.create :transaction, :budget => other_budget, :item => nil, :occurrence => nil, :date => @today - 1.day, :amount => 10000

      @budget.balance(@today).should == @budget.initial_balance
    end

    context '- current' do
      it 'should be concerned only with transactions' do
        # notice there are multiple occurrences of each item, but we tally only the transactions
        income_txn = Factory.create :transaction, :item => @income_item, :occurrence => @income_occurrence.date, :date => @income_occurrence.date
        expense_txn = Factory.create :transaction, :item => @expense_item, :occurrence => @expense_occurrence.date, :date => @expense_occurrence.date
        @budget.balance(@today).should == @budget.initial_balance + income_txn.amount - expense_txn.amount
      end

      it 'should include normal transactions' do
        # the previous example actually covered this, but in case it ever changes, i wanted to have something explicit
        income_txn = Factory.create :transaction, :item => @income_item, :occurrence => @income_occurrence.date, :date => @income_occurrence.date
        expense_txn = Factory.create :transaction, :item => @expense_item, :occurrence => @expense_occurrence.date, :date => @expense_occurrence.date
        @budget.balance(@today).should == @budget.initial_balance + income_txn.amount - expense_txn.amount
      end

      it 'should include orphaned transactions' do
        income_txn = Factory.create :transaction, :item => @income_item, :occurrence => nil, :date => @today - 1.day
        expense_txn = Factory.create :transaction, :item => @expense_item, :occurrence => nil, :date => @today - 1.week
        @budget.balance(@today).should == @budget.initial_balance + income_txn.amount - expense_txn.amount
      end

      it 'should include misc transactions' do
        income_txn = Factory.create :transaction, :budget => @budget, :item => nil, :occurrence => nil, :category => 'income', :date => @today - 1.day
        expense_txn = Factory.create :transaction, :budget => @budget, :item => nil, :occurrence => nil, :category => 'expense', :date => @today - 1.week
        @budget.balance(@today).should == @budget.initial_balance + income_txn.amount - expense_txn.amount
      end

      it 'should exclude transactions dated after today' do
        income_txn = Factory.create :transaction, :item => @income_item, :occurrence => @income_occurrence.date, :date => @today + 1.day
        expense_txn = Factory.create :transaction, :item => @expense_item, :occurrence => @expense_occurrence.date, :date => @today + 1.week
        @budget.balance(@today).should == @budget.initial_balance
      end
    end # context '- current'

    context '- projected' do
      before(:each) do
        @beginning_of_this_month = @today.beginning_of_month
        @tomorrow = @today + 1.day

        # redefine the occurrences so they are in the calculation period ... this will save us some frustrations
        @income_occurrence = @income_item.occurrences.between(@tomorrow, @end_of_next_month).first
        @expense_occurrence = @expense_item.occurrences.between(@tomorrow, @end_of_next_month).first
      end

      it 'should not include transactions beyond the end of the period' do
        income_txn = Factory.create :transaction, :item => @income_item, :occurrence => @income_occurrence.date, :date => @end_of_next_month + 1.week, :amount => @income_occurrence.amount + 50
        expense_txn = Factory.create :transaction, :item => @expense_item, :occurrence => @expense_occurrence.date, :date => @end_of_next_month + 1.week, :amount => @expense_occurrence.amount + 200
        income_items_amount = @income_item.occurrences.between(@beginning_of_this_month, @end_of_next_month).size * @income_item.amount
        expense_items_amount = @expense_item.occurrences.between(@beginning_of_this_month, @end_of_next_month).size * @expense_item.amount
        @budget.balance(@end_of_next_month).should == @budget.initial_balance + income_items_amount - expense_items_amount
      end

      it 'should not include occurrences beyond the end of the period' do
        @income_item.update_attributes :ends_on => @end_of_next_month + 1.month
        @expense_item.update_attributes :ends_on => @end_of_next_month + 1.month
        # notice that we are calculating the estimated occurrence amounts for the period and those after the period are excluded
        income_items_amount = @income_item.occurrences.between(@beginning_of_this_month, @end_of_next_month).size * @income_item.amount
        expense_items_amount = @expense_item.occurrences.between(@beginning_of_this_month, @end_of_next_month).size * @expense_item.amount
        @budget.balance(@end_of_next_month).should == @budget.initial_balance + income_items_amount - expense_items_amount
      end

      it 'should adjust for transactions (greater than occurrence.amount) up to today so they are not counted twice' do

        # remember that we redefined the occurrences to be the first ones after today
        income_txn = Factory.create :transaction, :item => @income_item, :occurrence => @income_occurrence.date, :date => @today, :amount => @income_occurrence.amount * 1.5
        expense_txn = Factory.create :transaction, :item => @expense_item, :occurrence => @expense_occurrence.date, :date => @today, :amount => @expense_occurrence.amount * 1.5

        income_occurrences_remaining = @income_item.occurrences.between(@beginning_of_this_month, @end_of_next_month).size
        income_occurrences_total = (income_occurrences_remaining - 1) * @income_item.amount

        expense_occurrences_remaining = @expense_item.occurrences.between(@beginning_of_this_month, @end_of_next_month).size
        expense_occurrences_total = (expense_occurrences_remaining - 1) * @expense_item.amount

        txns_total = income_txn.amount - expense_txn.amount
        occurrences_total = income_occurrences_total - expense_occurrences_total

        expected_balance = @budget.initial_balance + txns_total + occurrences_total
        @budget.balance(@end_of_next_month).should == expected_balance
      end

      it 'should adjust for transactions (less than occurrence.amount) up to today so they are not counted twice' do

        # remember that we redefined the occurrences to be the first ones after today
        income_txn = Factory.create :transaction, :item => @income_item, :occurrence => @income_occurrence.date, :date => @today, :amount => @income_occurrence.amount * 0.5
        expense_txn = Factory.create :transaction, :item => @expense_item, :occurrence => @expense_occurrence.date, :date => @today, :amount => @expense_occurrence.amount * 0.5

        income_occurrences_remaining = @income_item.occurrences.between(@beginning_of_this_month, @end_of_next_month).size
        income_occurrences_total = income_occurrences_remaining * @income_item.amount - income_txn.amount

        expense_occurrences_remaining = @expense_item.occurrences.between(@beginning_of_this_month, @end_of_next_month).size
        expense_occurrences_total = expense_occurrences_remaining * @expense_item.amount - expense_txn.amount

        txns_total = income_txn.amount - expense_txn.amount
        occurrences_total = income_occurrences_total - expense_occurrences_total

        expected_balance = @budget.initial_balance + txns_total + occurrences_total
        @budget.balance(@end_of_next_month).should == expected_balance
      end

      it 'should count transaction total when it is greater than occurrence amount' do
        # note that the txn.date is set after today because those up to today have already been counted
        income_txn = Factory.create :transaction, :item => @income_item, :occurrence => @income_occurrence.date, :date => @end_of_next_month - 1.week, :amount => @income_occurrence.amount + 1
        expense_txn = Factory.create :transaction, :item => @expense_item, :occurrence => @expense_occurrence.date, :date => @end_of_next_month - 1.week, :amount => @expense_occurrence.amount + 2

        # need all of the occurrences minus the ones the txns are tied to
        income_items_amount = (@income_item.occurrences.between(@beginning_of_this_month, @end_of_next_month).size - 1) * @income_item.amount
        expense_items_amount = (@expense_item.occurrences.between(@beginning_of_this_month, @end_of_next_month).size - 1) * @expense_item.amount

        @budget.balance(@end_of_next_month).should == @budget.initial_balance + (income_items_amount + income_txn.amount) - (expense_items_amount + expense_txn.amount)
      end

      it 'should count occurrence amount when it is greater than the transaction total' do
        # note that the txn.date is set after today because those up to today have already been counted
        income_txn = Factory.create :transaction, :item => @income_item, :occurrence => @income_occurrence.date, :date => @end_of_next_month - 1.week, :amount => @income_occurrence.amount - 1
        expense_txn = Factory.create :transaction, :item => @expense_item, :occurrence => @expense_occurrence.date, :date => @end_of_next_month - 1.week, :amount => @expense_occurrence.amount - 2

        # since no txn will be used, it's just the total of the occurrences
        income_items_amount = @income_item.occurrences.between(@beginning_of_this_month, @end_of_next_month).size * @income_item.amount
        expense_items_amount = @expense_item.occurrences.between(@beginning_of_this_month, @end_of_next_month).size * @expense_item.amount

        @budget.balance(@end_of_next_month).should == @budget.initial_balance + income_items_amount - expense_items_amount
      end

      it 'should count transactions in the calculation period that are tied to occurrences before the calculation period (txn.date in while txn.occurrence before)' do
        # note that the txn.date is set after today because those up to today have already been counted

        # get occurrences at the beginning of last month
        income_occurrence = @income_item.occurrences.first
        expense_occurrence = @expense_item.occurrences.first

        income_txn = Factory.create :transaction, :item => @income_item, :occurrence => income_occurrence.date, :date => @tomorrow, :amount => @income_occurrence.amount - 1
        expense_txn = Factory.create :transaction, :item => @expense_item, :occurrence => expense_occurrence.date, :date => @tomorrow, :amount => @expense_occurrence.amount - 2

        # since no txn will be used, it's just the total of the occurrences
        income_items_amount = @income_item.occurrences.between(@beginning_of_this_month, @end_of_next_month).size * @income_item.amount
        expense_items_amount = @expense_item.occurrences.between(@beginning_of_this_month, @end_of_next_month).size * @expense_item.amount

        @budget.balance(@end_of_next_month).should == @budget.initial_balance + (income_items_amount - expense_items_amount) + (income_txn.amount - expense_txn.amount)
      end

      it 'should count transactions in the calculation period that are tied to occurrences after the calculation period (txn.date in while txn.occurrence after)' do
        # note that the txn.date is set after today because those up to today have already been counted

        # need to extend the items first
        @income_item.update_attributes :ends_on => @end_of_next_month + 1.month
        @expense_item.update_attributes :ends_on => @end_of_next_month + 1.month

        # get occurrences after the end of next month
        income_occurrence = @income_item.occurrences.between(@end_of_next_month + 1.day, @income_item.ends_on).first
        expense_occurrence = @expense_item.occurrences.between(@end_of_next_month + 1.day, @expense_item.ends_on).first

        income_txn = Factory.create :transaction, :item => @income_item, :occurrence => income_occurrence.date, :date => @tomorrow, :amount => @income_occurrence.amount - 1
        expense_txn = Factory.create :transaction, :item => @expense_item, :occurrence => expense_occurrence.date, :date => @tomorrow, :amount => @expense_occurrence.amount - 2

        # since no txn will be used, it's just the total of the occurrences
        income_items_amount = @income_item.occurrences.between(@beginning_of_this_month, @end_of_next_month).size * @income_item.amount
        expense_items_amount = @expense_item.occurrences.between(@beginning_of_this_month, @end_of_next_month).size * @expense_item.amount

        @budget.balance(@end_of_next_month).should == @budget.initial_balance + (income_items_amount - expense_items_amount) + (income_txn.amount - expense_txn.amount)
      end
    end # context '- projected'
  end # describe '#balance'
end # describe Budget