require 'model_helper'

describe Transaction do
  it 'should belong to a budget' do
    budget = Factory.create :budget
    transaction = Factory.create :transaction, :budget => budget, :item => nil
    transaction.budget.should == budget
  end

  it 'should belong to an item' do
    item = Factory.create :item
    transaction = Factory.create :transaction, :item => item
    transaction.item.should == item
  end

  describe 'scopes:' do
    describe 'normal' do
      before(:each) do
        budget = Factory.create :budget
        item = Factory.create :item, :budget => budget
        occurrence = item.occurrences.ordinal(1)
        @normal_txn = Factory.create :transaction, :item => item, :occurrence => occurrence.date, :date => occurrence.date
        @orphan_txn = Factory.create :transaction, :item => item, :occurrence => nil, :date => item.starts_on + 1.day
        @misc_txn = Factory.create :transaction, :budget => budget, :item => nil, :date => item.starts_on + 2.days
        @normal_transactions = Transaction.normal.collect { |txn| txn.id }
      end

      it 'should not include misc transactions' do
        @normal_transactions.should_not include(@misc_txn.id)
      end

      it 'should include normal transactions' do
        @normal_transactions.should include(@normal_txn.id)
      end

      it 'should not include orphan transactions' do
        @normal_transactions.should_not include(@orphan_txn.id)
      end
    end # describe 'normal'

    describe 'misc' do
      before(:each) do
        budget = Factory.create :budget
        item = Factory.create :item, :budget => budget
        occurrence = item.occurrences.ordinal(1)
        @normal_txn = Factory.create :transaction, :item => item, :occurrence => occurrence.date, :date => occurrence.date
        @orphan_txn = Factory.create :transaction, :item => item, :occurrence => nil, :date => item.starts_on + 1.day
        @misc_txn = Factory.create :transaction, :budget => budget, :item => nil, :date => item.starts_on + 2.days
        @misc_transactions = Transaction.misc.collect { |txn| txn.id }
      end

      it 'should include misc transactions' do
        @misc_transactions.should include(@misc_txn.id)
      end

      # see GitHub issue #16 for why orphan txns should be included in the misc scope
      it 'should include orphan transactions' do
        @misc_transactions.should include(@orphan_txn.id)
      end

      it 'should not include normal transactions' do
        @misc_transactions.should_not include(@normal_txn.id)
      end
    end # describe 'misc'

    describe 'orphan' do
      before(:each) do
        budget = Factory.create :budget
        item = Factory.create :item, :budget => budget
        occurrence = item.occurrences.ordinal(1)
        @normal_txn = Factory.create :transaction, :item => item, :occurrence => occurrence.date, :date => occurrence.date
        @orphan_txn = Factory.create :transaction, :item => item, :occurrence => nil, :date => item.starts_on + 1.day
        @misc_txn = Factory.create :transaction, :budget => budget, :item => nil, :date => item.starts_on + 2.days
        @orphan_transactions = Transaction.orphan.collect { |txn| txn.id }
      end

      it 'should not include misc transactions' do
        @orphan_transactions.should_not include(@misc_txn.id)
      end

      it 'should not include normal transactions' do
        @orphan_transactions.should_not include(@normal_txn.id)
      end

      it 'should include orphan transactions' do
        @orphan_transactions.should include(@orphan_txn.id)
      end
    end # describe 'orphan'

    describe 'between' do
      before(:each) do
        beginning_of_month = Date.today.beginning_of_month
        end_of_month = beginning_of_month.end_of_month

        item = Factory.create :item
        occurrence = item.occurrences.first
        @before_txn_normal = Factory.create :transaction, :item => item, :occurrence => occurrence.date, :date => beginning_of_month - 1.week
        @before_txn_orphan = Factory.create :transaction, :item => item, :occurrence => nil, :date => beginning_of_month - 1.week
        @before_txn_misc = Factory.create :transaction, :item => nil, :occurrence => nil, :date => beginning_of_month - 1.week
        @between_txn_normal = Factory.create :transaction, :item => item, :occurrence => occurrence.date, :date => beginning_of_month + 1.week
        @between_txn_orphan = Factory.create :transaction, :item => item, :occurrence => nil, :date => beginning_of_month + 1.week
        @between_txn_misc = Factory.create :transaction, :item => nil, :occurrence => nil, :date => beginning_of_month + 1.week
        @after_txn_normal = Factory.create :transaction, :item => item, :occurrence => occurrence.date, :date => end_of_month + 1.week
        @after_txn_orphan = Factory.create :transaction, :item => item, :occurrence => nil, :date => end_of_month + 1.week
        @after_txn_misc = Factory.create :transaction, :item => nil, :occurrence => nil, :date => end_of_month + 1.week
        @between_transactions = Transaction.between(beginning_of_month, end_of_month).collect { |txn| txn.id }
      end

      it 'should not include transactions before the starting date' do
        [@before_txn_normal.id, @before_txn_orphan.id, @before_txn_misc.id].each { |txn_id| @between_transactions.should_not include(txn_id) }
      end

      it 'should not include transactions after the ending date' do
        [@after_txn_normal.id, @after_txn_orphan.id, @after_txn_misc.id].each { |txn_id| @between_transactions.should_not include(txn_id) }
      end

      it 'should include transactions between starting and ending dates' do
        [@between_txn_normal.id, @between_txn_orphan.id, @between_txn_misc.id].each { |txn_id| @between_transactions.should include(txn_id) }
      end
    end # describe 'between'

    describe 'up_to' do
      before(:each) do
        beginning_of_month = Date.today.beginning_of_month
        end_of_month = beginning_of_month.end_of_month

        item = Factory.create :item
        occurrence = item.occurrences.first
        @before_txn_normal = Factory.create :transaction, :item => item, :occurrence => occurrence.date, :date => beginning_of_month - 1.week
        @before_txn_orphan = Factory.create :transaction, :item => item, :occurrence => nil, :date => beginning_of_month - 1.week
        @before_txn_misc = Factory.create :transaction, :item => nil, :occurrence => nil, :date => beginning_of_month - 1.week
        @on_txn_normal = Factory.create :transaction, :item => item, :occurrence => occurrence.date, :date => end_of_month
        @on_txn_orphan = Factory.create :transaction, :item => item, :occurrence => nil, :date => end_of_month
        @on_txn_misc = Factory.create :transaction, :item => nil, :occurrence => nil, :date => end_of_month
        @after_txn_normal = Factory.create :transaction, :item => item, :occurrence => occurrence.date, :date => end_of_month + 1.week
        @after_txn_orphan = Factory.create :transaction, :item => item, :occurrence => nil, :date => end_of_month + 1.week
        @after_txn_misc = Factory.create :transaction, :item => nil, :occurrence => nil, :date => end_of_month + 1.week
        @up_to_transactions = Transaction.up_to(end_of_month).collect { |txn| txn.id }
      end

      it 'should not include transactions after the date' do
        [@after_txn_normal.id, @after_txn_orphan.id, @after_txn_misc.id].each { |txn_id| @up_to_transactions.should_not include(txn_id) }
      end

      it 'should include transactions on or before the ending date' do
        [@before_txn_normal.id, @before_txn_orphan.id, @before_txn_misc.id, @on_txn_normal.id, @on_txn_orphan.id, @on_txn_misc.id].each { |txn_id| @up_to_transactions.should include(txn_id) }
      end
    end # describe 'up_to'
  end # describe 'scopes'

  describe 'budget' do
    it 'should be required' do
      # the factory will create budget and item if not specified, and if there is
      # an item when we try to save the txn, that budget_id will be used. So to
      # test, we need to tell the factory to not create an item and then we
      # manually blank out the budget_id
      transaction = Factory.build :transaction, :item => nil
      transaction.budget_id = nil
      transaction.should have_at_least(1).error_on(:budget_id)
    end

    it 'should be set automatically when associated with item' do
      item = Factory.create :item, :schedule => 'weekly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-01-31')
      transaction = Factory.build :transaction, :item => item
      transaction.budget_id = nil
      transaction.should have(:no).errors_on(:budget_id)
    end
  end # describe 'budget'

  describe 'category' do
    context 'when associated with an item' do
      before(:each) do
        @transaction = Factory.build :transaction
      end

      it 'should not be required' do
        @transaction.should have(:no).errors_on(:category)
      end

      it 'should not be stored on the transaction' do
        @transaction.attributes[:category].should be_nil
      end

      it 'should be the category of the item' do
        @transaction.category.should == @transaction.item.category
      end
    end # context 'when associated with an item'

    context 'when not associated with an item' do
      it 'should be required' do
        transaction = Factory.build :transaction, :item => nil, :category => nil
        transaction.should have_at_least(1).error_on(:category)
      end
    end # context 'when the transaction is not associated with an item'
  end # describe 'category'

  describe '#income?' do
    context 'when associated with an item' do
      before(:each) do
        @item = Factory.create :item, :category => 'income'
      end

      it 'should be true when item category == income' do
        txn = Factory.build :transaction, :item => @item, :category => nil
        txn.income?.should be_true
      end

      it 'should not be true when item category != income' do
        @item.update_attribute :category, 'expense'
        txn = Factory.build :transaction, :item => @item, :category => nil
        txn.income?.should_not be_true
      end
    end # context 'when associated with an item'

    context 'when not associated with an item' do
      before(:each) do
        @txn = Factory.build :transaction, :item => nil
      end

      it 'should be true when category == income' do
        @txn.category = 'income'
        @txn.income?.should be_true
      end

      it 'should not be true when category != income' do
        @txn.category = 'expense'
        @txn.income?.should_not be_true
      end
    end # context 'when not associated with an item'
  end # describe '#income?'

  describe '#expense?' do
    context 'when associated with an item' do
      before(:each) do
        @item = Factory.create :item, :category => 'expense'
      end

      it 'should be true when item category == expense' do
        txn = Factory.build :transaction, :item => @item, :category => nil
        txn.expense?.should be_true
      end

      it 'should not be true when item category != expense' do
        @item.update_attribute :category, 'income'
        txn = Factory.build :transaction, :item => @item, :category => nil
        txn.expense?.should_not be_true
      end
    end # context 'when associated with an item'

    context 'when not associated with an item' do
      before(:each) do
        @txn = Factory.build :transaction, :item => nil
      end

      it 'should be true when category == expense' do
        @txn.category = 'expense'
        @txn.expense?.should be_true
      end

      it 'should not be true when category != expense' do
        @txn.category = 'income'
        @txn.expense?.should_not be_true
      end
    end # context 'when not associated with an item'
  end # describe '#expense?'

  describe 'date' do
    it 'should be required' do
      transaction = Factory.build :transaction, :date => nil
      transaction.should have_at_least(1).error_on(:date)
    end

    it 'can be earlier than item.starts_on' do
      item = Factory.create :item, :schedule => 'weekly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-01-31')
      transaction = Factory.build :transaction, :item => item, :date => item.starts_on - 1.day
      transaction.should have(:no).errors_on(:date)
    end

    it 'can be earlier than budget.created_at' do
      budget = Factory.create :budget
      item = Factory.create :item, :schedule => 'weekly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-01-31')
      transaction = Factory.build :transaction, :item => item, :date => budget.created_at.to_date - 1.day
      transaction.should have(:no).errors_on(:date)
    end
  end # describe 'date'

  describe 'description' do
    it 'should not be required' do
      transaction = Factory.build :transaction, :description => nil
      transaction.should have(:no).errors_on(:description)
    end

    it 'should return the description when given' do
      description = 'Given Description'
      transaction = Factory.build :transaction, :description => description
      transaction.description.should == description
    end

    it "should return '#{Constants::Transactions::NO_DESCRIPTION}' when normal and no description given" do
      transaction = Factory.build :transaction, :description => nil
      transaction.normal?.should be_true
      transaction.description.should == Constants::Transactions::NO_DESCRIPTION
    end

    it "should return '#{Constants::Transactions::NO_DESCRIPTION}' when misc and no description given" do
      transaction = Factory.build :transaction, :item => nil, :description => nil
      transaction.misc?.should be_true
      transaction.description.should == Constants::Transactions::NO_DESCRIPTION
    end

    it 'should return item.name when orphaned and no description given' do
      transaction = Factory.build :transaction, :occurrence => nil, :description => nil
      transaction.orphan?.should be_true
      transaction.description.should == transaction.item.name
    end
  end # describe 'description'

  describe 'amount' do
    it 'should be required' do
      transaction = Factory.build :transaction, :amount => nil
      transaction.should have_at_least(1).error_on(:amount)
    end

    it 'should be greater than 0' do
      transaction = Factory.build :transaction, :amount => 0
      transaction.should have_at_least(1).error_on(:amount)

      transaction = Factory.build :transaction, :amount => -1
      transaction.should have_at_least(1).error_on(:amount)
    end

    it 'should truncate decimal values' do
      transaction = Factory.build :transaction, :amount => 123.45
      transaction.should have(:no).errors_on(:amount)
      transaction.amount.should == 123
    end
  end # describe 'amount'

  describe 'occurrence' do
    context 'when associated with an item' do
      it 'should not be required' do
        item = Factory.create :item, :schedule => 'weekly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-01-31')
        transaction = Factory.build :transaction, :item => item, :occurrence => nil
        transaction.should have(:no).errors_on(:occurrence)
      end

      it 'should be the date of one of the item occurrences' do
        item = Factory.create :item, :schedule => 'weekly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-01-31')

        transaction = Factory.build :transaction, :item => item, :occurrence => Date.parse('2012-02-05')
        transaction.should have_at_least(1).error_on(:occurrence)
        
        transaction = Factory.build :transaction, :item => item, :occurrence => Date.parse('2012-01-08')
        transaction.should have(:no).errors_on(:occurrence)
      end
    end # context 'when associated with an item'

    context 'when not associated with an item' do
      it 'should not be required' do
        transaction = Factory.build :transaction, :item => nil, :occurrence => nil
        transaction.should have(:no).errors_on(:occurrence)
      end

      it 'should be nil' do
        # going to actually create the txn because the logic is in the before_save callback path
        transaction = Factory.create :transaction, :item => nil, :occurrence => Date.today
        transaction.occurrence.should be_nil
      end
    end # context 'when not associated with an item'
  end # describe 'occurrence'

  describe '#misc?' do
    it 'should not be true when associated with an item' do
      # going to actually create the txn because the logic is in the before_save callback path
      item = Factory.create :item, :schedule => 'weekly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-01-31')
      transaction = Factory.create :transaction, :item => item, :occurrence => Date.parse('2012-01-08')
      transaction.misc?.should_not be_true
    end

    it 'should be true when not associated with an item' do
      # going to actually create the txn because the logic is in the before_save callback path
      transaction = Factory.create :transaction, :item => nil
      transaction.misc?.should be_true
    end
  end # describe '#misc?'

  describe '#orphan?' do
    before(:each) do
      item = Factory.create :item, :schedule => 'weekly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-01-31')
      @transaction = Factory.create :transaction, :item => item, :occurrence => Date.parse('2012-01-08')
    end

    it 'should be false when transaction is misc' do
      @transaction.update_attribute :item_id, nil
      @transaction.misc?.should be_true
      @transaction.orphan?.should_not be_true
    end

    it 'should not be true when occurrence is valid' do
      @transaction.misc?.should_not be_true
      @transaction.orphan?.should_not be_true
    end

    it 'should be true when occurrence is invalid/empty' do
      @transaction.misc?.should_not be_true
      @transaction.update_column :occurrence, nil
      @transaction.orphan?.should be_true
    end
  end # describe '#orphan?'

  describe '#orphan!' do
    before(:each) do
      item = Factory.create :item, :schedule => 'weekly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-01-31')
      @transaction = Factory.create :transaction, :item => item, :occurrence => Date.parse('2012-01-08')
      @transaction.orphan!
    end

    it 'should make the transaction an orphan' do
      @transaction.orphan?.should be_true
    end
  end # describe '#orphan!'

  describe '#misc!' do
    before(:each) do
      item = Factory.create :item, :schedule => 'weekly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-01-31')
      @transaction = Factory.create :transaction, :item => item, :occurrence => Date.parse('2012-01-08')
      @transaction.misc!
    end

    it 'should make the transaction misc' do
      @transaction.misc?.should be_true
    end
  end # describe '#misc!'

  describe '#normal?' do
    before(:each) do
      item = Factory.create :item, :schedule => 'weekly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-01-31')
      @transaction = Factory.create :transaction, :item => item, :occurrence => Date.parse('2012-01-08')
    end

    it 'should be false when transaction is misc' do
      @transaction.misc!
      @transaction.misc?.should be_true
      @transaction.normal?.should_not be_true
    end

    it 'should be false when transaction is orphan' do
      @transaction.orphan!
      @transaction.orphan?.should be_true
      @transaction.normal?.should_not be_true
    end

    it 'should be true when transaction is neither misc? nor orphan?' do
      @transaction.misc?.should_not be_true
      @transaction.orphan?.should_not be_true
      @transaction.normal?.should be_true
    end
  end # describe '#normal?'
end
