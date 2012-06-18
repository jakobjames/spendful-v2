require 'model_helper'

describe Item do
  it 'should belong to budget' do
    budget = Factory.create :budget
    item = Factory.create :item, :budget => budget
    item.budget.should == budget
  end

  it 'should have many transactions' do
    item = Factory.create :item
    transaction = Factory.create :transaction, :item => item
    # reloading because the safe item's process accesses the transactions association
    # which means it has already been loaded and needs to be reloaded to test
    item.reload.transactions.should == [transaction]
  end
  
  describe 'scopes:' do
    describe 'income' do
      before(:each) do
        Factory.create :item, :category => 'income'
        Factory.create :item, :category => 'expense'
        @income_items = Item.income
      end

      it 'should return only income items' do
        @income_items.size.should == 1
        @income_items.first.category.should == 'income'
      end
    end # describe 'income'

    describe 'expense' do
      before(:each) do
        Factory.create :item, :category => 'income'
        Factory.create :item, :category => 'expense'
        @expense_items = Item.expense
      end

      it 'should return only expense items' do
        @expense_items.size.should == 1
        @expense_items.first.category.should == 'expense'
      end
    end # describe 'expense'

    describe 'between' do
      before(:each) do
        @beginning_of_month = Date.today.beginning_of_month
        @end_of_month = Date.today.end_of_month
      end

      it 'should not include items that begin and end before the period' do
        beginning_of_previous_month = @beginning_of_month - 1.month
        Factory.create :item, :starts_on => beginning_of_previous_month, :ends_on => beginning_of_previous_month.end_of_month
        Item.between(@beginning_of_month, @end_of_month).should be_empty
      end

      it 'should not include items that begin and end after the period' do
        beginning_of_next_month = @beginning_of_month + 1.month
        Factory.create :item, :starts_on => beginning_of_next_month, :ends_on => beginning_of_next_month.end_of_month
        Item.between(@beginning_of_month, @end_of_month).should be_empty
      end

      it 'should include items that begin before the period and end after the period' do
        beginning_of_previous_month = @beginning_of_month - 1.month
        end_of_next_month = (@beginning_of_month + 1.month).end_of_month
        Factory.create :item, :starts_on => beginning_of_previous_month, :ends_on => end_of_next_month
        Item.between(@beginning_of_month, @end_of_month).should_not be_empty
      end

      it 'should include items that begin before the period and end during the period' do
        beginning_of_previous_month = @beginning_of_month - 1.month
        Factory.create :item, :starts_on => beginning_of_previous_month, :ends_on => @end_of_month - 1.day
        Item.between(@beginning_of_month, @end_of_month).should_not be_empty
      end

      it 'should include items that begin during the period and end after the period' do
        end_of_next_month = (@beginning_of_month + 1.month).end_of_month
        Factory.create :item, :starts_on => @beginning_of_month + 1.day, :ends_on => end_of_next_month
        Item.between(@beginning_of_month, @end_of_month).should_not be_empty
      end
    end # describe 'between'
  end # describe 'scopes:'

  describe 'budget' do
    it 'should be required' do
      # the factory will create budget if not specified, so to
      # test, we need to manually blank out the budget_id
      item = Factory.build :item
      item.budget_id = nil
      item.should have_at_least(1).error_on(:budget_id)
    end
  end # describe 'budget'

  describe 'category' do
    it 'should be required' do
      item = Factory.build :item, :category => nil
      item.should have_at_least(1).error_on(:category)
    end

    it "should be one of #{Constants::Items::CATEGORIES.join(' or ')}" do
      Constants::Items::CATEGORIES.each do |category|
        item = Factory.build :item, :category => category
        item.should have(:no).errors_on(:category)
      end

      %w(blah blag flibby-jibbit).each do |category|
        item = Factory.build :item, :category => category
        item.should have_at_least(1).error_on(:category)
      end
    end
  end # describe 'category'

  describe '#income?' do
    before(:each) do
      @item = Factory.build :item
    end

    it 'should be true when item category == income' do
      @item.category = 'income'
      @item.income?.should be_true
    end

    it 'should not be true when item category != income' do
      @item.category = 'expense'
      @item.income?.should_not be_true
    end
  end # describe '#income?'

  describe '#expense?' do
    before(:each) do
      @item = Factory.build :item
    end

    it 'should be true when item category == expense' do
      @item.category = 'expense'
      @item.expense?.should be_true
    end

    it 'should not be true when item category != expense' do
      @item.category = 'income'
      @item.expense?.should_not be_true
    end
  end # describe '#expense?'

  describe 'name' do
    it 'should be required' do
      item = Factory.build :item, :name => nil
      item.should have_at_least(1).error_on(:name)
    end

    it 'should be unique by budget and starts_on' do
      item_1 = Factory.create :item
      item_2 = Factory.build :item, :budget => item_1.budget, :name => item_1.name, :starts_on => item_1.starts_on
      item_2.should have_at_least(1).error_on(:name)
    end

    it 'should be reusable by different starts_on' do
      item_1 = Factory.create :item
      item_2 = Factory.build :item, :budget => item_1.budget, :name => item_1.name, :starts_on => item_1.starts_on + 1.day
      item_2.should have(:no).errors_on(:name)
    end

    it 'should be reusable by different budgets with same starts_on' do
      budget_1 = Factory.create :budget
      budget_2 = Factory.build :budget, :user => budget_1.user
      item_1 = Factory.create :item, :budget => budget_1
      item_2 = Factory.build :item, :budget => budget_2, :name => item_1.name, :starts_on => item_1.starts_on
      item_2.should have(:no).errors_on(:name)
    end
  end # describe 'name'

  describe 'slug' do
    before(:each) do
      @item_1 = Factory.create :item
      @item_2 = Factory.create :item, :budget => @item_1.budget, :name => @item_1.name, :starts_on => @item_1.starts_on + 1.day
      @item_3 = Factory.create :item, :budget => @item_1.budget, :name => @item_1.name, :starts_on => @item_1.starts_on + 2.days
    end

    it 'should be set automatically' do
      @item_1.slug.should_not be_nil
    end

    it 'should change when the name changes' do
      old_slug = @item_1.slug
      @item_1.update_attribute :name, @item_1.name.reverse
      @item_1.slug.should_not == old_slug
    end

    context 'when used one time' do
      it 'should be the name parameterized' do
        @item_1.slug.should == @item_1.name.parameterize
      end
    end

    context 'when used multiple times' do
      it 'should be the name parameterized with a counter value' do
        @item_2.slug.should == "#{@item_2.name.parameterize}-2"
        @item_3.slug.should == "#{@item_3.name.parameterize}-3"
      end
    end
  end # describe 'slug'

  describe 'amount' do
    it 'should be required' do
      item = Factory.build :item, :amount => nil
      item.should have_at_least(1).error_on(:amount)
    end

    it 'should be greater than or equal to 0' do
      item = Factory.build :item, :amount => 0
      item.should have(:no).errors_on(:amount)

      item = Factory.build :item, :amount => -1
      item.should have_at_least(1).error_on(:amount)
    end

    it 'should truncate decimal values' do
      item = Factory.build :item, :amount => 123.45
      item.should have(:no).errors_on(:amount)
      item.amount.should == 123
    end
  end # describe 'amount'

  describe 'schedule' do
    it 'should default to once' do
      item = Factory.create :item, :schedule => nil
      item.schedule.should == 'once'
    end

    it "should be one of #{Constants::Items::SCHEDULES.join(' or ')}" do
      Constants::Items::SCHEDULES.each do |schedule|
        item = Factory.build :item, :schedule => schedule
        item.should have(:no).errors_on(:schedule)
      end

      %w(blah blag flibby-jibbit).each do |schedule|
        item = Factory.build :item, :schedule => schedule
        item.should have_at_least(1).error_on(:schedule)
      end
    end
  end # describe 'schedule'

  describe 'schedule helpers' do
    Constants::Items::SCHEDULES.each do |schedule|
      describe "#{schedule}?" do
        before(:each) do
          @item = Factory.build :item, :schedule => schedule
        end

        it "should be true when schedule == #{schedule}" do
          @item.send("#{schedule}?").should be_true
        end

        it "should not be true when schedule != #{schedule}" do
          @item.schedule = schedule.reverse
          @item.send("#{schedule}?").should_not be_true
        end
      end
    end # Constants::SCHEDULES.each
  end # describe 'schedule helpers'

  describe 'starts_on' do
    it 'should be required' do
      item = Factory.build :item, :starts_on => nil
      item.should have_at_least(1).error_on(:starts_on)
    end

    it 'can be earlier than budget.created_at' do
      budget = Factory.create :budget
      item = Factory.create :item, :schedule => 'weekly', :starts_on => budget.created_at.to_date - 1.day
      item.should have(:no).errors_on(:starts_on)
    end
  end # describe 'starts_on'

  describe 'changing starts_on' do
    before(:each) do
      @old_date = Date.today
      @new_date = @old_date + 3.weeks
      @item = Factory.create :item, :starts_on => @old_date, :ends_on => @old_date + 5.weeks
    end

    it 'should update the ice_cube_schedule' do
      # point of reference
      @item.ice_cube_schedule.start_time.to_date.should == @old_date
      @item.starts_on = @new_date
      @item.save
      different_copy_of_item = Item.find_by_id @item.id
      different_copy_of_item.ice_cube_schedule.start_time.to_date.should == @new_date
    end

    it 'should fail if new date is after an occurrence with a transaction' do
      occurrence = @item.occurrences.first
      Factory.create :transaction, :item => @item, :occurrence => occurrence.date, :date => @new_date
      @item.starts_on = @new_date
      @item.should have_at_least(1).error_on(:starts_on)
    end

    it 'should succeed if new date is after an orphaned transaction' do
      Factory.create :transaction, :item => @item, :occurrence => nil, :date => @old_date
      @item.starts_on = @new_date
      @item.should have(:no).errors_on(:starts_on)
    end
  end # describe 'changing starts_on'

  describe 'ends_on' do
    it 'should not be required' do
      item = Factory.build :item, :ends_on => nil
      item.should have(:no).errors_on(:ends_on)
    end

    it 'should be nil when schedule is once' do
      # need to actually create the item because the logic is in before_validation callback path
      item = Factory.create :item, :schedule => 'once'
      item.ends_on.should be_nil
    end

    it 'when set, should be after starts_on' do
      item = Factory.build :item, :schedule => 'monthly', :starts_on => Date.today, :ends_on => Date.today - 1
      item.should have_at_least(1).error_on(:ends_on)

      item = Factory.build :item, :schedule => 'monthly', :starts_on => Date.today, :ends_on => Date.today
      item.should have_at_least(1).error_on(:ends_on)

      item = Factory.build :item, :schedule => 'monthly', :starts_on => Date.today, :ends_on => Date.today + 1
      item.should have(:no).errors_on(:ends_on)
    end
  end # describe 'ends_on'

  describe 'changing ends_on' do
    before(:each) do
      @old_date = Date.today
      @new_date = @old_date + 1.day
      @item = Factory.create :item, :starts_on => @old_date - 1.month, :ends_on => @old_date
    end

    it 'should update the ice_cube_schedule' do
      # point of reference
      @item.ice_cube_schedule.end_time.to_date.should == @old_date
      @item.ends_on = @new_date
      @item.save
      different_copy_of_item = Item.find_by_id @item.id
      different_copy_of_item.ice_cube_schedule.end_time.to_date.should == @new_date
    end
  end # describe 'changing ends_on'

  describe 'schedule_details' do
    before(:each) do
      @item = Factory.create :item
    end

    it 'should be set automatically' do
      @item.schedule_details.should_not be_nil
    end

    it 'should not lose changes to the ice_cube_schedule' do
      @item.ice_cube_schedule.add_exception_time Time.now
      @item.save
      different_copy_of_item = Item.find_by_id @item.id
      different_copy_of_item.ice_cube_schedule.exception_times.should_not be_empty
    end
  end # describe 'schedule_details'

  describe '#ice_cube_schedule' do
    it 'should be an instance of IceCube::Schedule' do
      item = Factory.create :item
      item.ice_cube_schedule.class.should == IceCube::Schedule
    end

    it 'should be memoized' do
      item = Factory.create :item
      item.ice_cube_schedule.add_exception_time Time.now
      item.ice_cube_schedule.exception_times.should_not be_empty
    end

    it 'should not have a recurrence rule when schedule is once' do
      item = Factory.create :item, :schedule => 'once'
      item.ice_cube_schedule.recurrence_rules.should be_empty
    end

    it 'should have a recurrence rule when schedule is weekly' do
      today = Date.today
      item = Factory.create :item, :schedule => 'weekly', :starts_on => today, :ends_on => today + 1.month
      item.ice_cube_schedule.recurrence_rules.should_not be_empty
      (item.ice_cube_schedule.next_occurrence).to_date.should == today + 1.week
    end

    it 'should have a recurrence rule when schedule is fornightly' do
      today = Date.today
      item = Factory.create :item, :schedule => 'fortnightly', :starts_on => today, :ends_on => today + 1.month
      item.ice_cube_schedule.recurrence_rules.should_not be_empty
      (item.ice_cube_schedule.next_occurrence).to_date.should == today + 2.weeks
    end

    it 'should have a recurrence rule when schedule is monthly' do
      # Check that an item created on the 31st of one month recurs on the 30th of a month with 30 days and the last day of February.
      # Using a leap year to check February 29th also
      starts_on = Date.parse('2012-01-31')
      item = Factory.create :item, :schedule => 'monthly', :starts_on => starts_on, :ends_on => starts_on + 1.year
      item.ice_cube_schedule.recurrence_rules.should_not be_empty
      ['2012-02-29', '2012-03-31', '2012-04-30'].each { |date| item.ice_cube_schedule.all_occurrences.should include(Time.parse(date)) }
    end

    it 'should have a recurrence rule when schedule is yearly' do
      today = Date.parse('2012-01-01')
      item = Factory.create :item, :schedule => 'yearly', :starts_on => today, :ends_on => today + 2.years
      item.ice_cube_schedule.recurrence_rules.should_not be_empty
      (item.ice_cube_schedule.next_occurrence).to_date.should == today + 1.year
    end

    it 'should be updated when item.schedule changes' do
      today = Date.today
      item = Factory.create :item, :schedule => 'once', :starts_on => today

      # sanity check
      item.ice_cube_schedule.recurrence_rules.should be_empty

      occurrence = item.occurrences.first
      occurrence.update_attribute :schedule, 'weekly'

      item.ice_cube_schedule.recurrence_rules.should_not be_empty
      (item.ice_cube_schedule.next_occurrence).to_date.should == today + 1.week
    end

  end # describe '#ice_cube_schedule'

  describe '#occurrences' do
    it 'should exist' do
      Item.new.respond_to?(:occurrences).should be_true
    end
  end # describe '#occurrences'

  describe 'destroy' do
    before(:each) do
      @item = Factory.create :item
      @txn = Factory.create :transaction, :item => @item
      @item.destroy
    end

    it 'should make any associated transactions misc' do
      @txn.reload.misc?.should be_true
    end
  end # describe 'destroy'
end # describe Item
