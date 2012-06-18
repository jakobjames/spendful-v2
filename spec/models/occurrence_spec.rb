require 'model_helper'

describe Occurrence do
  describe 'newly built' do
    before(:each) do
      @item = Factory.create :item, :schedule => 'weekly', :starts_on => Date.today.beginning_of_year, :ends_on => Date.today.end_of_year
      @date = @item.starts_on
      @occurrence = Factory.build :occurrence, :item => @item, :date => @date
    end

    specify 'should not be dirty' do
      @occurrence.changed?.should_not be_true
    end

    specify 'item should be the item initalized with' do
      @occurrence.item.should == @item
    end

    specify 'item_id should be the id of the item initalized with' do
      @occurrence.item_id.should == @item.id
    end

    specify 'date should be the date initalized with' do
      @occurrence.date.should == @date
    end

    specify 'date should trigger dirty tracking when changed' do
      @occurrence.date = @date + 1.day
      @occurrence.changed?.should be_true
      @occurrence.date_changed?.should be_true
    end

    specify 'category should be the category of the item' do
      @occurrence.category.should == @item.category
    end

    specify 'name should be the name of the item' do
      @occurrence.name.should == @item.name
    end

    specify 'name should trigger dirty tracking when changed' do
      @occurrence.name = @item.name.reverse
      @occurrence.changed?.should be_true
      @occurrence.name_changed?.should be_true
    end

    specify 'schedule should be the schedule of the item' do
      @occurrence.schedule.should == @item.schedule
    end

    specify 'schedule should trigger dirty tracking when changed' do
      schedules = Constants::Items::SCHEDULES.dup
      schedules.delete @item.schedule
      @occurrence.schedule = schedules.sample
      @occurrence.changed?.should be_true
      @occurrence.schedule_changed?.should be_true
    end

    specify 'starts_on should be the starts_on of the item' do
      @occurrence.starts_on.should == @item.starts_on
    end

    specify 'starts_on should trigger dirty tracking when changed' do
      @occurrence.starts_on = @item.starts_on + 1.day
      @occurrence.changed?.should be_true
      @occurrence.starts_on_changed?.should be_true
    end

    specify 'ends_on should be the ends_on of the item' do
      @occurrence.ends_on.should == @item.ends_on
    end

    specify 'ends_on should trigger dirty tracking when changed' do
      @occurrence.ends_on = @item.ends_on + 1.day
      @occurrence.changed?.should be_true
      @occurrence.ends_on_changed?.should be_true
    end

    specify 'amount should be the amount of the item' do
      @occurrence.amount.should == @item.amount
    end

    specify 'amount should trigger dirty tracking when changed' do
      @occurrence.amount = @item.amount + 1
      @occurrence.changed?.should be_true
      @occurrence.amount_changed?.should be_true
    end
  end # describe 'newly built'

  describe '#transactions' do
    before(:each) do
      item = Factory.create :item, :schedule => 'weekly', :starts_on => Date.today.beginning_of_month, :ends_on => Date.today.end_of_month
      @first_occurrence = Factory.build :occurrence, :item => item, :date => item.starts_on
      second_occurrence = Factory.build :occurrence, :item => item, :date => item.starts_on + 1.week

      @txn_1 = Factory.create :transaction, :item => item, :occurrence => @first_occurrence.date, :date => Date.today
      @txn_2 = Factory.create :transaction, :item => item, :occurrence => second_occurrence.date, :date => Date.today + 1.day
      @txn_3 = Factory.create :transaction, :item => item, :occurrence => @first_occurrence.date, :date => Date.today - 1.day
    end

    specify 'should be the transactions associated with the specific occurrence' do
      txn_ids = @first_occurrence.transactions.collect { |txn| txn.id }
      txn_ids.should include(@txn_1.id)
      txn_ids.should include(@txn_3.id)
      txn_ids.should_not include(@txn_2.id)
    end

    specify 'should order the transactions by date' do
      txns = @first_occurrence.transactions
      txns.first.date.should == @txn_3.date
      txns.last.date.should == @txn_1.date
    end
  end # describe '#transactions'

  describe '#actual' do
    before(:each) do
      item = Factory.create :item, :schedule => 'weekly', :starts_on => Date.today.beginning_of_month, :ends_on => Date.today.end_of_month
      @first_occurrence = Factory.build :occurrence, :item => item, :date => item.starts_on
      second_occurrence = Factory.build :occurrence, :item => item, :date => item.starts_on + 1.week

      @txn_1 = Factory.create :transaction, :item => item, :occurrence => @first_occurrence.date, :date => Date.today
      @txn_2 = Factory.create :transaction, :item => item, :occurrence => second_occurrence.date, :date => Date.today + 1.day
      @txn_3 = Factory.create :transaction, :item => item, :occurrence => @first_occurrence.date, :date => Date.today - 1.day
    end

    it 'should total the amount of transactions' do
      @first_occurrence.actual.should == @txn_1.amount + @txn_3.amount
    end
  end # describe '#actual'

  describe '#update_attribute' do
    before(:each) do
      @item = Factory.create :item, :schedule => 'weekly', :starts_on => Date.today.beginning_of_month, :ends_on => Date.today.end_of_month
      @occurrence = Factory.build :occurrence, :item => @item, :date => @item.starts_on
      @occurrence.stub :update_attributes
    end

    specify 'should call #update_attributes' do
      name = @item.name.reverse
      @occurrence.should_receive(:update_attributes).with(hash_including(:name => name))
      @occurrence.update_attribute :name, name
    end
  end # describe '#update_attribute'

  describe '#update_attributes' do
    before(:each) do
      @item = Factory.create :item, :schedule => 'weekly', :starts_on => Date.today.beginning_of_month, :ends_on => Date.today.end_of_month
      @occurrence = Factory.build :occurrence, :item => @item, :date => @item.starts_on
      @occurrence.stub :save
    end

    specify 'should assign new values to the attributes' do
      schedules = Constants::Items::SCHEDULES.dup
      schedules.delete @item.schedule
      new_values = {
        :date => @occurrence.date + 1.day,
        :name => @item.name.reverse,
        :schedule => schedules.sample,
        :starts_on => @item.starts_on + 1.day,
        :ends_on => @item.ends_on + 1.day,
        :amount => @item.amount + 1
      }

      @occurrence.update_attributes new_values
      [:date, :name, :schedule, :starts_on, :ends_on, :amount].each { |attribute| @occurrence.send(attribute).should == new_values[attribute] }
    end

    specify 'should not reassign item' do
      new_item = Factory.create :item, :budget => @item.budget

      # by 'association'
      @occurrence.update_attribute :item, new_item
      @occurrence.item.should == @item

      # by 'association' id
      @occurrence.update_attribute :item_id, new_item.id
      @occurrence.item_id.should == @item.id
    end

    specify 'should call #save' do
      @occurrence.should_receive :save
      @occurrence.update_attributes {}
    end

    specify 'should do nothing if a hash not passed' do
      @occurrence.should_not_receive :save
      @occurrence.update_attributes nil
    end
  end # describe '#update_attributes'

  describe '#save' do
    before(:each) do
      @item = Factory.create :item, :schedule => 'weekly', :starts_on => Date.today.beginning_of_month, :ends_on => Date.today.end_of_month
      @occurrence = Factory.build :occurrence, :item => @item, :date => @item.starts_on
      @occurrence.stub :handle_date_change
      @occurrence.stub :handle_name_change
      @occurrence.stub :handle_schedule_change
      @occurrence.stub :handle_starts_on_change
      @occurrence.stub :handle_ends_on_change
      @occurrence.stub :handle_amount_change
      @occurrence.stub :create_or_update_item
    end

    specify 'should handle occurrence.date change' do
      @occurrence.should_receive :handle_date_change
      @occurrence.date = @occurrence.date + 1
      @occurrence.save
    end

    specify 'should handle item.name change' do
      @occurrence.should_receive :handle_name_change
      @occurrence.name = @occurrence.name.reverse
      @occurrence.save
    end

    specify 'should handle item.schedule change' do
      schedules = Constants::Items::SCHEDULES.dup
      schedules.delete @item.schedule
      @occurrence.should_receive :handle_schedule_change
      @occurrence.schedule = schedules.sample
      @occurrence.save
    end

    specify 'should handle item.starts_on change' do
      @occurrence.should_receive :handle_starts_on_change
      @occurrence.starts_on = @occurrence.starts_on + 1
      @occurrence.save
    end

    specify 'should handle item.ends_on change' do
      @occurrence.should_receive :handle_ends_on_change
      @occurrence.ends_on = @occurrence.ends_on + 1
      @occurrence.save
    end

    specify 'should handle item.amount change' do
      @occurrence.should_receive :handle_amount_change
      @occurrence.amount = @occurrence.amount + 1
      @occurrence.save
    end

    specify 'should create or update the item' do
      @occurrence.should_receive :create_or_update_item
      @occurrence.amount = @occurrence.amount + 1
      @occurrence.save
    end

    specify 'should do nothing and return true if no changes' do
      @occurrence.should_not_receive :handle_date_change
      @occurrence.should_not_receive :handle_name_change
      @occurrence.should_not_receive :handle_schedule_change
      @occurrence.should_not_receive :handle_starts_on_change
      @occurrence.should_not_receive :handle_ends_on_change
      @occurrence.should_not_receive :handle_amount_change
      @occurrence.should_not_receive :create_or_update_item
      @occurrence.save.should be_true
    end

    specify 'should reset dirty tracking' do
      @occurrence.name = @occurrence.name.reverse
      # point of reference
      @occurrence.changed?.should be_true
      @occurrence.save
      @occurrence.changed?.should_not be_true
    end

    specify 'should return true when successful' do
      @occurrence.stub(:create_or_update_item).and_return(true)
      @occurrence.name = @occurrence.name.reverse
      @occurrence.save.should be_true
    end

    specify 'should return false when not successful' do
      @occurrence.stub(:create_or_update_item).and_return(false)
      @occurrence.name = @occurrence.name.reverse
      @occurrence.save.should_not be_true
    end
  end # describe '#save'

  describe '#first?' do
    before(:each) do
      @today = Date.today
      @item = Factory.create :item, :schedule => 'weekly', :starts_on => @today, :ends_on => @today + 1.month
    end

    specify 'should be true when this is the first occurrence' do
      occurrence = @item.occurrences.fetch @today
      occurrence.first?.should be_true
    end

    specify 'should not be true when this is not the first occurrence' do
      occurrence = @item.occurrences.fetch @today + 1.week
      occurrence.first?.should_not be_true
    end
  end # describe '#first?'

  describe '#index' do
    before(:each) do
      today = Date.today
      item = Factory.create :item, :schedule => 'weekly', :starts_on => today, :ends_on => today + 1.month
      @first_occurrence, @second_occurrence, @third_occurrence = item.occurrences.limit(3)
    end

    specify 'should return the index of this occurrence in the item.occurrences collection' do
      @first_occurrence.index.should == 0
      @second_occurrence.index.should == 1
      @third_occurrence.index.should == 2
    end
  end

  describe '#ordinal' do
    before(:each) do
      today = Date.today
      item = Factory.create :item, :schedule => 'weekly', :starts_on => today, :ends_on => today + 1.month
      @first_occurrence, @second_occurrence, @third_occurrence = item.occurrences.limit(3)
    end

    specify 'should return the oridinal position of this occurrence in the item.occurrences collection' do
      @first_occurrence.ordinal.should == 1
      @second_occurrence.ordinal.should == 2
      @third_occurrence.ordinal.should == 3
    end
  end # describe '#ordinal'

  describe 'validations' do
    before(:each) do
      @item = Factory.create :item, :schedule => 'weekly', :starts_on => Date.today, :ends_on => Date.today + 5.weeks
    end

    context 'when editing the first occurrence' do
      before(:each) do
        @occurrence = @item.occurrences.first
      end

      specify 'should fail when name is invalid' do
        @occurrence.update_attribute :name, nil
        @occurrence.valid?.should_not be_true
        @occurrence.should have_at_least(1).error_on(:name)
      end

      specify 'should fail when schedule is invalid' do
        @occurrence.update_attribute :schedule, @item.schedule.reverse
        @occurrence.valid?.should_not be_true
        @occurrence.should have_at_least(1).error_on(:schedule)
      end

      specify 'should fail when starts_on is invalid' do
        @occurrence.update_attribute :starts_on, nil
        @occurrence.valid?.should_not be_true
        @occurrence.should have_at_least(1).error_on(:starts_on)
      end

      specify 'should fail when ends_on is invalid' do
        @occurrence.update_attribute :ends_on, @item.starts_on - 1.day
        @occurrence.valid?.should_not be_true
        @occurrence.should have_at_least(1).error_on(:ends_on)
      end

      specify 'should fail when amount is invalid' do
        @occurrence.update_attribute :amount, -1000
        @occurrence.valid?.should_not be_true
        @occurrence.should have_at_least(1).error_on(:amount)
      end

      specify 'should pass when all attributes are valid' do
        @occurrence.update_attribute :name, 'New Name'
        @occurrence.valid?.should be_true
      end
    end # context 'when editing the first occurrence' do

    context 'when editing a later occurrence' do
      before(:each) do
        @occurrence = @item.occurrences.ordinal(3)
      end

      specify 'existing item should not be saved' do
        # I did have this checking to make sure .save didn't get called,
        # but when I added ActiveRecord::Base.transaction, it gets called
        # all the time now, but changes will get rolled back if something
        # fails. So I had to change this spec to check something else, and
        # I chose to use ends_on because that should get changed if the
        # schedule changes.
        old_item_ends_on = @item.ends_on
        @occurrence.update_attribute :schedule, @item.schedule.reverse
        @item.reload.ends_on.should == old_item_ends_on
      end

      specify 'should fail when name is invalid' do
        @occurrence.update_attribute :name, nil
        @occurrence.valid?.should_not be_true
        @occurrence.should have_at_least(1).error_on(:name)
      end

      specify 'should fail when schedule is invalid' do
        @occurrence.update_attribute :schedule, @item.schedule.reverse
        @occurrence.valid?.should_not be_true
        @occurrence.should have_at_least(1).error_on(:schedule)
      end

      specify 'should fail when starts_on is invalid' do
        @occurrence.update_attribute :starts_on, nil
        @occurrence.valid?.should_not be_true
        @occurrence.should have_at_least(1).error_on(:starts_on)
      end

      specify 'should fail when ends_on is invalid' do
        @occurrence.update_attribute :ends_on, @item.starts_on - 1.day
        @occurrence.valid?.should_not be_true
        @occurrence.should have_at_least(1).error_on(:ends_on)
      end

      specify 'should fail when amount is invalid' do
        @occurrence.update_attribute :amount, -1000
        @occurrence.valid?.should_not be_true
        @occurrence.should have_at_least(1).error_on(:amount)
      end

      specify 'should pass when all attributes are valid' do
        @occurrence.update_attribute :name, 'New Name'
        @occurrence.valid?.should be_true
      end
    end # when editing a later occurrence
  end # describe 'validations'

  describe 'changing occurrence.date when the item schedule is once' do
    before(:each) do
      @old_date = Date.today
      @new_date = @old_date + 1.day
      @item = Factory.create :item, :schedule => 'once', :starts_on => @old_date
      @occurrence = @item.occurrences.fetch @old_date
    end

    specify 'should not create a new item' do
      expect { @occurrence.update_attribute :date, @new_date }.to_not change { Item.count }
    end

    specify 'should change the date of the occurrence' do
      @occurrence.update_attribute :date, @new_date
      @item.occurrences.fetch(@old_date).should be_nil
      @item.occurrences.fetch(@new_date).should_not be_nil
    end

    specify 'should change item.starts_on' do
      @occurrence.update_attribute :date, @new_date
      @item.starts_on.should == @new_date
    end

    specify 'should continue to associate transactions with the occurrence' do
      txn = Factory.create :transaction, :item => @item, :occurrence => @occurrence.date, :date => @occurrence.date
      @occurrence.update_attribute :date, @new_date
      @occurrence.transactions.first.id.should == txn.id
    end
  end # describe 'changing occurrence.date when the item schedule is once'

  describe 'changing occurrence.date when the item schedule is not once' do
    # should fail if
    # => the new date is already an occurrence

    # if the new date is not between item.starts_on and item.ends_on
    # => create a new once item for the new date
    # => any txns tied to this occurrence stay with it but get moved to the new item

    # if it is the first occurrence:
    # => change the item.starts_on to the second occurrence

    # if it is not the first occurrence
    # => add an exclusion to the original item's ice_cube_schedule

    # if the new date is between item.starts_on and item.ends_on
    # => update txn.occurrence to new date

    # if it is the first occurrence
    #   if the new date is before the second occurrence
    #     => create a new once item for the new date
    #     => change the item.starts_on to the second occurrence
    #   else
    #     => add recurrence_time to ice_cube_schedule for new occurrence date

    # if it is not the first occurrence
    # => add exclusion to ice_cube_schedule for old occurrence date

    before(:each) do
      @old_date = Date.today
      @ends_on = @old_date + 5.weeks
      @item = Factory.create :item, :schedule => 'weekly', :starts_on => @old_date, :ends_on => @ends_on
    end

    context 'and an occurrence already exists on the new date' do
      before(:each) do
        @new_date = @old_date + 2.weeks
        @occurrence = @item.occurrences.fetch @old_date
      end

      specify 'should fail' do
        @occurrence.update_attribute :date, @new_date
        @occurrence.date.should == @old_date

        # need to check errors this way because the errors are not being added during the validation
        # process. if RSpec's have_at_least(n).errors_on is used, it will call #valid? which
        # empties the errors before running validations
        @occurrence.errors[:date].should_not be_empty
      end
    end # context 'and an occurrence already exists on the new date'

    context 'and the new date is before item.starts_on' do
      before(:each) do
        @new_date = @old_date - 1.week
      end

      context 'and this is the first occurrence' do
        before(:each) do
          @occurrence = @item.occurrences.fetch @old_date
          @txn = Factory.create :transaction, :item => @item, :occurrence => @occurrence.date, :date => @occurrence.date
        end

        specify 'should create a new item' do
          expect { @occurrence.update_attribute :date, @new_date }.to change { Item.count }.by(1)
        end

        specify 'should set the new item budget properly' do
          @occurrence.update_attribute :date, @new_date
          Item.last.budget_id.should == @item.budget_id
        end
        
        specify 'should set the new item category properly' do
          @occurrence.update_attribute :date, @new_date
          Item.last.category.should == @item.category
        end

        specify 'should set the new item schedule to once' do
          @occurrence.update_attribute :date, @new_date
          Item.last.schedule.should == 'once'
        end

        specify 'should set the new item amount properly' do
          @occurrence.update_attribute :date, @new_date
          Item.last.amount.should == @item.amount
        end

        specify 'should set the new item starts_on to the new date' do
          @occurrence.update_attribute :date, @new_date
          Item.last.starts_on.should == @new_date
        end

        specify 'should continue to associate any transactions with the occurrence' do
          @occurrence.update_attribute :date, @new_date
          @occurrence.transactions.first.id.should == @txn.id
        end

        specify 'should move any transactions to the new item' do
          @occurrence.update_attribute :date, @new_date
          Item.last.transactions.first.id.should == @txn.id
          @item.transactions.all.size.should == 0
        end

        specify 'should change the old item.starts_on to the second occurrence' do
          second_occurrence = @item.occurrences.limit(2).last
          @occurrence.update_attribute :date, @new_date
          @item.reload.starts_on.should == second_occurrence.date
        end
      end # context 'and this is the first occurrence'

      context 'and this is not the first occurrence' do
        before(:each) do
          @occurrence = @item.occurrences.fetch(@old_date + 2.weeks)
          @txn = Factory.create :transaction, :item => @item, :occurrence => @occurrence.date, :date => @occurrence.date
        end

        specify 'should create a new item' do
          expect { @occurrence.update_attribute :date, @new_date }.to change { Item.count }.by(1)
        end

        specify 'should set the new item budget properly' do
          @occurrence.update_attribute :date, @new_date
          Item.last.budget_id.should == @item.budget_id
        end
        
        specify 'should set the new item category properly' do
          @occurrence.update_attribute :date, @new_date
          Item.last.category.should == @item.category
        end

        specify 'should set the new item schedule to once' do
          @occurrence.update_attribute :date, @new_date
          Item.last.schedule.should == 'once'
        end

        specify 'should set the new item amount properly' do
          @occurrence.update_attribute :date, @new_date
          Item.last.amount.should == @item.amount
        end

        specify 'should set the new item starts_on to the new date' do
          @occurrence.update_attribute :date, @new_date
          Item.last.starts_on.should == @new_date
        end

        specify 'should continue to associate any transactions with the occurrence', :flicker do
          @occurrence.update_attribute :date, @new_date
          @occurrence.transactions.first.id.should == @txn.id
        end

        specify 'should move any transactions to the new item' do
          @occurrence.update_attribute :date, @new_date
          Item.last.transactions.first.id.should == @txn.id
          @item.transactions.all.size.should == 0
        end

        specify 'should add an exclusion to the old item for the old date' do
          occurrence_old_date = @occurrence.date
          @occurrence.update_attribute :date, @new_date
          @item.occurrences.exists?(occurrence_old_date).should_not be_true
        end
      end # context 'and this is not the first occurrence'
    end # context 'and the new date is before item.starts_on'

    context 'and the new date is after item.ends_on' do
      before(:each) do
        @new_date = @ends_on + 1.week
      end

      context 'and this is the first occurrence' do
        before(:each) do
          @occurrence = @item.occurrences.fetch @old_date
          @txn = Factory.create :transaction, :item => @item, :occurrence => @occurrence.date, :date => @occurrence.date
        end

        specify 'should create a new item' do
          expect { @occurrence.update_attribute :date, @new_date }.to change { Item.count }.by(1)
        end

        specify 'should set the new item budget properly' do
          @occurrence.update_attribute :date, @new_date
          Item.last.budget_id.should == @item.budget_id
        end
        
        specify 'should set the new item category properly' do
          @occurrence.update_attribute :date, @new_date
          Item.last.category.should == @item.category
        end

        specify 'should set the new item schedule to once' do
          @occurrence.update_attribute :date, @new_date
          Item.last.schedule.should == 'once'
        end

        specify 'should set the new item amount properly' do
          @occurrence.update_attribute :date, @new_date
          Item.last.amount.should == @item.amount
        end

        specify 'should set the new item starts_on to the new date' do
          @occurrence.update_attribute :date, @new_date
          Item.last.starts_on.should == @new_date
        end

        specify 'should continue to associate any transactions with the occurrence' do
          @occurrence.update_attribute :date, @new_date
          @occurrence.transactions.first.id.should == @txn.id
        end

        specify 'should move any transactions to the new item' do
          @occurrence.update_attribute :date, @new_date
          Item.last.transactions.first.id.should == @txn.id
          @item.transactions.all.size.should == 0
        end

        specify 'should change the old item.starts_on to the second occurrence' do
          second_occurrence = @item.occurrences.limit(2).last
          @occurrence.update_attribute :date, @new_date
          @item.reload.starts_on.should == second_occurrence.date
        end
      end # context 'and this is the first occurrence'

      context 'and this is not the first occurrence' do
        before(:each) do
          @occurrence = @item.occurrences.fetch(@old_date + 2.weeks)
          @txn = Factory.create :transaction, :item => @item, :occurrence => @occurrence.date, :date => @occurrence.date
        end

        specify 'should create a new item' do
          expect { @occurrence.update_attribute :date, @new_date }.to change { Item.count }.by(1)
        end

        specify 'should set the new item budget properly' do
          @occurrence.update_attribute :date, @new_date
          Item.last.budget_id.should == @item.budget_id
        end
        
        specify 'should set the new item category properly' do
          @occurrence.update_attribute :date, @new_date
          Item.last.category.should == @item.category
        end

        specify 'should set the new item schedule to once' do
          @occurrence.update_attribute :date, @new_date
          Item.last.schedule.should == 'once'
        end

        specify 'should set the new item amount properly' do
          @occurrence.update_attribute :date, @new_date
          Item.last.amount.should == @item.amount
        end

        specify 'should set the new item starts_on to the new date' do
          @occurrence.update_attribute :date, @new_date
          Item.last.starts_on.should == @new_date
        end

        specify 'should continue to associate any transactions with the occurrence' do
          @occurrence.update_attribute :date, @new_date
          @occurrence.transactions.first.id.should == @txn.id
        end

        specify 'should move any transactions to the new item' do
          @occurrence.update_attribute :date, @new_date
          Item.last.transactions.first.id.should == @txn.id
          @item.transactions.all.size.should == 0
        end

        specify 'should add an exclusion to the old item for the old date' do
          occurrence_old_date = @occurrence.date
          @occurrence.update_attribute :date, @new_date
          @item.occurrences.exists?(occurrence_old_date).should_not be_true
        end
      end # context 'and this is not the first occurrence'
    end # context 'and the new date is after item.ends_on'

    context 'and the new date is between item.starts_on and item.ends_on' do
      context 'and this is the first occurrence' do
        before(:each) do
          @second_occurrence = @item.occurrences.limit(2).last
        end

        context 'and the new date is before the second occurrence' do
          before(:each) do
            @new_date = @second_occurrence.date - 1.day
            @occurrence = @item.occurrences.fetch @old_date
            @txn = Factory.create :transaction, :item => @item, :occurrence => @occurrence.date, :date => @occurrence.date
          end

          specify 'should create a new item' do
           expect { @occurrence.update_attribute :date, @new_date }.to change { Item.count }.by(1)
          end

          specify 'should set the new item budget properly' do
           @occurrence.update_attribute :date, @new_date
           Item.last.budget_id.should == @item.budget_id
          end

          specify 'should set the new item category properly' do
           @occurrence.update_attribute :date, @new_date
           Item.last.category.should == @item.category
          end

          specify 'should set the new item schedule to once' do
           @occurrence.update_attribute :date, @new_date
           Item.last.schedule.should == 'once'
          end

          specify 'should set the new item amount properly' do
           @occurrence.update_attribute :date, @new_date
           Item.last.amount.should == @item.amount
          end

          specify 'should set the new item starts_on to the new date' do
           @occurrence.update_attribute :date, @new_date
           Item.last.starts_on.should == @new_date
          end

          specify 'should continue to associate any transactions with the occurrence' do
           @occurrence.update_attribute :date, @new_date
           @occurrence.transactions.first.id.should == @txn.id
          end

          specify 'should move any transactions to the new item' do
           @occurrence.update_attribute :date, @new_date
           Item.last.transactions.first.id.should == @txn.id
           @item.transactions.all.size.should == 0
          end

          specify 'should change the item.starts_on to the second occurrence' do
            @occurrence.update_attribute :date, @new_date
            @item.reload.starts_on.should == @second_occurrence.date
          end
        end # context 'and the new date is before the second occurrence'

        context 'and the new date is after the second occurrence' do
          before(:each) do
            @new_date = @second_occurrence.date + 1.day
            @occurrence = @item.occurrences.fetch @old_date
            @txn = Factory.create :transaction, :item => @item, :occurrence => @occurrence.date, :date => @occurrence.date
          end

          specify 'should change the item.starts_on to the second occurrence' do
            @occurrence.update_attribute :date, @new_date
            @item.reload.starts_on.should == @second_occurrence.date
          end

          specify 'should add a recurrence_time for the new date' do
            @occurrence.update_attribute :date, @new_date
            @item.occurrences.exists?(@new_date).should be_true
          end

          specify 'should continue to associate the transactions with the occurrence' do
            @occurrence.update_attribute :date, @new_date
            @occurrence.transactions.first.id.should == @txn.id
          end
        end # context 'and the new date is after the second occurrence'
      end # context 'and this is the first occurrence'

      context 'and this is not the first occurrence' do
        before(:each) do
          # simulating moving the occurrence 1 day, as in when one occurrence of something is rescheduled
          @new_date = @old_date + 1.week + 1.day
          @old_occurrence_date = @old_date + 1.week
          @occurrence = @item.occurrences.fetch @old_occurrence_date
          @txn = Factory.create :transaction, :item => @item, :occurrence => @occurrence.date, :date => @occurrence.date
        end

        specify 'should add the old date as an exclusion' do
          @occurrence.update_attribute :date, @new_date
          @item.occurrences.exists?(@old_occurrence_date).should_not be_true
        end

        specify 'should continue to associate the transactions with the occurrence' do
          @occurrence.update_attribute :date, @new_date
          @occurrence.transactions.first.id.should == @txn.id
        end
      end # context 'and this is not the first occurrence'
    end # context 'and the new date is between item.starts_on and item.ends_on'
  end # describe 'changing occurrence.date when the item schedule is not once'

  describe 'changing item.name' do
    before(:each) do
      @item = Factory.create :item
      @new_name = @item.name.reverse
      @occurrence = @item.occurrences.limit(1).first
    end

    specify 'should change the name on the item' do
      @occurrence.update_attribute :name, @new_name
      @item.reload.name.should == @new_name
    end

    specify 'should change the name on the occurrence' do
      @occurrence.update_attribute :name, @new_name
      @occurrence.name.should == @new_name
    end

    specify 'should not create a new item' do
      expect { @occurrence.update_attribute :name, @new_name }.to_not change { Item.count }
    end
  end # describe 'changing item.name'

  describe 'changing item.schedule when item.schedule is once' do
    before(:each) do
      @old_schedule = 'once'
      @new_schedule = 'weekly'

      starts_on = Date.today.beginning_of_month
      @item = Factory.create :item, :schedule => @old_schedule, :starts_on => starts_on
      @occurrence = @item.occurrences.fetch starts_on
    end

    specify 'should not create a new item' do
      expect { @occurrence.update_attribute :schedule, @new_schedule }.to_not change { Item.count }
    end

    specify 'should change the item schedule' do
      @occurrence.update_attribute :schedule, @new_schedule
      @item.reload.schedule.should == @new_schedule
    end

    specify 'should change the occurrence schedule' do
      @occurrence.update_attribute :schedule, @new_schedule
      @occurrence.schedule.should == @new_schedule
    end
  end # describe 'changing item.schedule when item.schedule is once'

  describe 'changing item.schedule when item.schedule is not once' do
    # should fail if
    # => normal transactions exist *after* this occurrence

    # any txns associated with this occurrence should remain so

    # if this is the first occurrence
    # => do not create a new item
    # => update the schedule

    # if this is not the first occurrence
    # => create a new item with starts_on = the occurrence date
    # => set the old item's ends_on to occurrence.date - 1.day
    # => move this occurrence's txns to the new item

    before(:each) do
      @old_schedule = 'weekly'
      @new_schedule = 'monthly'
      @starts_on = Date.today.beginning_of_month
      @ends_on = @starts_on + 6.months

      @item = Factory.create :item, :schedule => @old_schedule, :starts_on => @starts_on, :ends_on => @ends_on
      @occurrence = @item.occurrences.ordinal(4)
    end

    specify 'should fail if normal transactions exist after this occurrence' do
      date = @occurrence.date + 1.week
      Factory.create :transaction, :item => @item, :occurrence => date, :date => @occurrence.date - 1.week
      @occurrence.update_attribute :schedule, @new_schedule
      @occurrence.schedule.should == @old_schedule

      # need to check errors this way because the errors are not being added during the validation
      # process. if RSpec's have_at_least(n).errors_on is used, it will call #valid? which
      # empties the errors before running validations
      @occurrence.errors[:schedule].should_not be_empty
    end

    specify 'should succeed if orphan transactions exist after this occurrence' do
      date = @occurrence.date + 1.week
      Factory.create :transaction, :item => @item, :occurrence => nil, :date => @occurrence.date
      @occurrence.update_attribute :schedule, @new_schedule
      @occurrence.schedule.should == @new_schedule

      # need to check errors this way because the errors are not being added during the validation
      # process. if RSpec's have_at_least(n).errors_on is used, it will call #valid? which
      # empties the errors before running validations
      @occurrence.errors[:schedule].should be_empty
    end

    specify 'should succeed if normal transactions exist on or before this occurrence' do
      dates = [@occurrence.date, @occurrence.date - 1.week]

      dates.each do |date|
        Factory.create :transaction, :item => @item, :occurrence => date, :date => @occurrence.date + 1.week
        @occurrence.update_attribute :schedule, @new_schedule
        @occurrence.schedule.should == @new_schedule
        
        # need to check errors this way because the errors are not being added during the validation
        # process. if RSpec's have_at_least(n).errors_on is used, it will call #valid? which
        # empties the errors before running validations
        @occurrence.errors[:schedule].should be_empty

        Transaction.delete_all
      end
    end

    context 'and this is the first occurrence' do
      before(:each) do
        @occurrence = @item.occurrences.fetch @starts_on
      end

      specify 'should not create a new item' do
        expect { @occurrence.update_attribute :schedule, @new_schedule }.to_not change { Item.count }
      end

      specify 'should change the item schedule' do
        @occurrence.update_attribute :schedule, @new_schedule
        @item.reload.schedule.should == @new_schedule
      end

      specify 'should change the occurrence schedule' do
        @occurrence.update_attribute :schedule, @new_schedule
        @occurrence.schedule.should == @new_schedule
      end
    end # context 'and this is the first occurrence'

    context 'and this is the second occurrence' do
      # this is a special case because changing the schedule results in a new item being created which starts on
      # the occurrence being edited. the existing item's ends_on will be changed to the occurrence before this one,
      # which, in the case of editing the second occurrence, will be the first. that results in the existing item's
      # ends_on being set to its starts_on, so we want to just change it to a 'once' item.

      before(:each) do
        @occurrence = @item.occurrences.ordinal(2)
      end

      specify 'should change the existing item schedule to once' do
        @occurrence.update_attribute :schedule, @new_schedule
        @item.reload.once?.should be_true
      end

      specify 'should create a new item' do
        expect { @occurrence.update_attribute :schedule, @new_schedule }.to change { Item.count }.by(1)
      end

      specify 'should set the new item budget properly' do
        @occurrence.update_attribute :schedule, @new_schedule
        Item.last.budget_id.should == @item.budget_id
      end
      
      specify 'should set the new item category properly' do
        @occurrence.update_attribute :schedule, @new_schedule
        Item.last.category.should == @item.category
      end

      specify 'should set the new item amount properly' do
        @occurrence.update_attribute :schedule, @new_schedule
        Item.last.amount.should == @item.amount
      end

      specify 'should set the new item schedule to the new schedule' do
        @occurrence.update_attribute :schedule, @new_schedule
        Item.last.schedule.should == @new_schedule
      end

      specify 'should set the new item starts_on to the occurrence date' do
        @occurrence.update_attribute :schedule, @new_schedule
        Item.last.starts_on.should == @occurrence.date
      end

      specify 'should associate the occurrence with the new item' do
        @occurrence.update_attribute :schedule, @new_schedule
        @occurrence.item.id.should == Item.last.id
        @occurrence.item_id.should == @occurrence.item.id
      end
    end # context 'and this is the second occurrence'

    context 'and this is not the first or second occurrence' do
      before(:each) do
        @occurrence = @item.occurrences.ordinal(3)
      end

      specify 'should change the existing item ends_on to the occurrence before this one' do
        previous_occurrence = @item.occurrences.ordinal(2)
        @occurrence.update_attribute :schedule, @new_schedule
        @item.reload.ends_on.should == previous_occurrence.date
      end

      specify 'should create a new item' do
        expect { @occurrence.update_attribute :schedule, @new_schedule }.to change { Item.count }.by(1)
      end

      specify 'should set the new item budget properly' do
        @occurrence.update_attribute :schedule, @new_schedule
        Item.last.budget_id.should == @item.budget_id
      end
      
      specify 'should set the new item category properly' do
        @occurrence.update_attribute :schedule, @new_schedule
        Item.last.category.should == @item.category
      end

      specify 'should set the new item amount properly' do
        @occurrence.update_attribute :schedule, @new_schedule
        Item.last.amount.should == @item.amount
      end

      specify 'should set the new item schedule to the new schedule' do
        @occurrence.update_attribute :schedule, @new_schedule
        Item.last.schedule.should == @new_schedule
      end

      specify 'should set the new item starts_on to the occurrence date' do
        @occurrence.update_attribute :schedule, @new_schedule
        Item.last.starts_on.should == @occurrence.date
      end

      specify 'should associate the occurrence with the new item' do
        @occurrence.update_attribute :schedule, @new_schedule
        @occurrence.item.id.should == Item.last.id
        @occurrence.item_id.should == @occurrence.item.id
      end
    end # context 'and this is not the first or second occurrence'
  end # describe 'changing item.schedule when item.schedule is not once'

  describe 'changing item.starts_on when item.schedule is once' do
    # when it's a once item, we can change starts_on to whatever date we want,
    # we just need to make sure to change occurrence.date and txn.occurrence
    # to the new date as wells

    before(:each) do
      @old_starts_on = Date.today.beginning_of_month
      @new_starts_on = @old_starts_on + 2.weeks

      @item = Factory.create :item, :schedule => 'once', :starts_on => @old_starts_on
      @occurrence = @item.occurrences.first
    end

    specify 'should not create a new item' do
      expect { @occurrence.update_attribute :starts_on, @new_starts_on }.to_not change { Item.count }
    end

    specify 'should change the item starts_on' do
      @occurrence.update_attribute :starts_on, @new_starts_on
      @item.reload.starts_on.should == @new_starts_on
    end

    specify 'should change the occurrence starts_on' do
      @occurrence.update_attribute :starts_on, @new_starts_on
      @occurrence.starts_on.should == @new_starts_on
    end

    specify 'should change the occurrence date to the new starts_on' do
      @occurrence.update_attribute :starts_on, @new_starts_on
      @occurrence.date.should == @new_starts_on
    end

    specify 'should keep transactions associated with the occurrence' do
      txn = Factory.create :transaction, :item => @item, :occurrence => @occurrence.date, :date => @occurrence.date
      @occurrence.update_attribute :starts_on, @new_starts_on
      txn.reload.occurrence.should == @occurrence.date
    end
  end # describe 'changing item.starts_on when item.schedule is once'

  describe 'changing item.starts_on when item.schedule is not once' do
    # should fail if
    # => any normal transactions exist

    # if it doesn't fail, do not create a new item. just change the date

    # if the new date == item.ends_on, make the item once

    before(:each) do
      @old_starts_on = Date.today.beginning_of_month
      @ends_on = @old_starts_on + 6.months - 1.day
      @new_starts_on = @old_starts_on + 2.weeks

      @item = Factory.create :item, :schedule => 'weekly', :starts_on => @old_starts_on, :ends_on => @ends_on
      @occurrence = @item.occurrences.ordinal(4)
    end

    specify 'should fail if any normal transactions exist' do
      dates = [@occurrence.date - 1.week, @occurrence.date, @occurrence.date + 1.week]

      dates.each do |date|
        Factory.create :transaction, :item => @item, :occurrence => date, :date => date - 1.day
        @occurrence.update_attribute :starts_on, @occurrence.date
        @occurrence.starts_on.should == @old_starts_on
        # need to check errors this way because the errors are not being added during the validation
        # process. if RSpec's have_at_least(n).errors_on is used, it will call #valid? which
        # empties the errors before running validations
        @occurrence.errors[:starts_on].should_not be_empty

        Transaction.delete_all
      end
    end

    specify 'should not fail because orphan transactions exist' do
      dates = [@occurrence.date - 1.week, @occurrence.date, @occurrence.date + 1.week]

      dates.each do |date|
        Factory.create :transaction, :item => @item, :occurrence => nil, :date => date
        @occurrence.update_attribute :starts_on, @occurrence.date
        @occurrence.starts_on.should == @occurrence.date
        # need to check errors this way because the errors are not being added during the validation
        # process. if RSpec's have_at_least(n).errors_on is used, it will call #valid? which
        # empties the errors before running validations
        @occurrence.errors[:starts_on].should be_empty

        Transaction.delete_all
      end
    end

    specify 'should not create a new item' do
      expect { @occurrence.update_attribute :starts_on, @new_starts_on }.to_not change { Item.count }
    end

    specify 'should change the item starts_on' do
      @occurrence.update_attribute :starts_on, @new_starts_on
      @item.reload.starts_on.should == @new_starts_on
    end

    specify 'should change the occurrence starts_on' do
      @occurrence.update_attribute :starts_on, @new_starts_on
      @occurrence.starts_on.should == @new_starts_on
    end

    specify 'should change item.schedule to once if new date == item.ends_on' do
      @occurrence.update_attribute :starts_on, @item.ends_on
      @item.reload.once?.should be_true
    end
  end # describe 'changing item.starts_on when item.schedule is not once'

  describe 'changing item.ends_on' do
    # should fail if
    # => transactions exist after the new date

    # if it doesn't fail, do not create a new item, just change the date

    # if the new date is == item.starts_on, make the item once

    before(:each) do
      starts_on = Date.today.beginning_of_month
      @old_ends_on = starts_on + 5.months - 1.day
      @new_ends_on = @old_ends_on + 1.month

      @item = Factory.create :item, :schedule => 'weekly', :starts_on => starts_on, :ends_on => @old_ends_on
      @occurrence = @item.occurrences.ordinal(4)
    end

    specify 'should fail if normal transactions exist after the new date' do
      date = @occurrence.date + 1.week
      Factory.create :transaction, :item => @item, :occurrence => date, :date => @occurrence.date - 1.week
      @occurrence.update_attribute :ends_on, @occurrence.date
      @occurrence.ends_on.should == @old_ends_on
      # need to check errors this way because the errors are not being added during the validation
      # process. if RSpec's have_at_least(n).errors_on is used, it will call #valid? which
      # empties the errors before running validations
      @occurrence.errors[:ends_on].should_not be_empty
    end

    specify 'should not fail because orphan transactions exist after the new date' do
      date = @occurrence.date + 1.week
      Factory.create :transaction, :item => @item, :occurrence => nil, :date => date
      @occurrence.update_attribute :ends_on, @occurrence.date
      @occurrence.ends_on.should == @occurrence.date
      # need to check errors this way because the errors are not being added during the validation
      # process. if RSpec's have_at_least(n).errors_on is used, it will call #valid? which
      # empties the errors before running validations
      @occurrence.errors[:ends_on].should be_empty
    end

    specify 'should succeed if normal transactions exist on or before the new date' do
      dates = [@occurrence.date, @occurrence.date - 1.week]

      dates.each do |date|
        Factory.create :transaction, :item => @item, :occurrence => date, :date => @occurrence.date + 1.week
        @occurrence.update_attribute :ends_on, @occurrence.date
        @occurrence.ends_on.should == @occurrence.date
        # need to check errors this way because the errors are not being added during the validation
        # process. if RSpec's have_at_least(n).errors_on is used, it will call #valid? which
        # empties the errors before running validations
        @occurrence.errors[:ends_on].should be_empty

        Transaction.delete_all
      end
    end

    specify 'should not create a new item' do
      expect { @occurrence.update_attribute :ends_on, @new_ends_on }.to_not change { Item.count }
    end

    specify 'should change the ends_on on the item' do
      @occurrence.update_attribute :ends_on, @new_ends_on
      @item.reload.ends_on.should == @new_ends_on
    end

    specify 'should change the ends_on on the occurrence' do
      @occurrence.update_attribute :ends_on, @new_ends_on
      @occurrence.ends_on.should == @new_ends_on
    end

    specify 'should change item.schedule to once if new date == item.starts_on' do
      @occurrence.update_attribute :ends_on, @item.starts_on
      @item.reload.once?.should be_true
    end
  end # describe 'changing item.ends_on when item.schedule is not once'

  describe 'changing item.amount when the item schedule is once' do
    before(:each) do
      @old_amount = SecureRandom.random_number(1000) + 100
      @new_amount = @old_amount.div 2
      @today = Date.today
      @item = Factory.create :item, :schedule => 'once', :starts_on => @today, :amount => @old_amount
      @occurrence = @item.occurrences.first
    end

    specify 'should not create a new item' do
      expect { @occurrence.update_attribute :amount, @new_amount }.to_not change { Item.count }
    end

    specify 'should change the amount of the occurrence' do
      @occurrence.update_attribute :amount, @new_amount
      @occurrence.amount.should == @new_amount
    end

    specify 'should change item.amount' do
      @occurrence.update_attribute :amount, @new_amount
      @item.reload.amount.should == @new_amount
    end
  end # describe 'changing item.amount when the item schedule is once'
    
  describe 'changing item.amount when the item schedule is not once' do
    before(:each) do
      @old_amount = SecureRandom.random_number(1000) + 100
      @new_amount = @old_amount.div 2
      @today = Date.today
      @ends_on = @today + 5.weeks
      @item = Factory.create :item, :schedule => 'weekly', :starts_on => @today, :ends_on => @ends_on, :amount => @old_amount
      @occurrence = @item.occurrences.ordinal(4)
    end

    specify 'should fail if normal transactions exist after this occurrence', :flicker do
      date = @occurrence.date + 1.week
      Factory.create :transaction, :item => @item, :occurrence => date, :date => @occurrence.date - 1.week
      @occurrence.update_attribute :amount, @new_amount
      @occurrence.amount.should == @old_amount

      # need to check errors this way because the errors are not being added during the validation
      # process. if RSpec's have_at_least(n).errors_on is used, it will call #valid? which
      # empties the errors before running validations
      @occurrence.errors[:amount].should_not be_empty
    end

    specify 'should not fail because orphan transactions exist after this occurrence' do
      date = @occurrence.date + 1.week
      Factory.create :transaction, :item => @item, :occurrence => nil, :date => date
      @occurrence.update_attribute :amount, @new_amount
      @occurrence.amount.should == @new_amount

      # need to check errors this way because the errors are not being added during the validation
      # process. if RSpec's have_at_least(n).errors_on is used, it will call #valid? which
      # empties the errors before running validations
      @occurrence.errors[:amount].should be_empty
    end

    specify 'should succeed if normal transactions exist on or before this occurrence' do
      dates = [@occurrence.date, @occurrence.date - 1.week]

      dates.each do |date|
        Factory.create :transaction, :item => @item, :occurrence => date, :date => @occurrence.date + 1.week
        @occurrence.update_attribute :amount, @new_amount
        @occurrence.amount.should == @new_amount
        
        # need to check errors this way because the errors are not being added during the validation
        # process. if RSpec's have_at_least(n).errors_on is used, it will call #valid? which
        # empties the errors before running validations
        @occurrence.errors[:amount].should be_empty

        Transaction.delete_all
      end
    end

    context 'and this is the first occurrence' do
      before(:each) do
        @occurrence = @item.occurrences.first
      end

      specify 'should not create a new item' do
        expect { @occurrence.update_attribute :amount, @new_amount }.to_not change { Item.count }
      end

      specify 'should change the amount of the occurrence' do
        @occurrence.update_attribute :amount, @new_amount
        @occurrence.amount.should == @new_amount
      end

      specify 'should change item.amount' do
        @occurrence.update_attribute :amount, @new_amount
        @item.reload.amount.should == @new_amount
      end
    end # context 'and this is the first occurrence'

    context 'and this is the second occurrence' do
      # this is a special case because changing the amount results in a new item being created which starts on
      # the occurrence being edited. the existing item's ends_on will be changed to the occurrence before this one,
      # which, in the case of editing the second occurrence, will be the first. that results in the existing item's
      # ends_on being set to its starts_on, so we want to just change it to a 'once' item.

      before(:each) do
        @occurrence = @item.occurrences.ordinal(2)
      end

      specify 'should change the existing item schedule to once' do
        @occurrence.update_attribute :amount, @new_amount
        @item.reload.once?.should be_true
      end

      specify 'should create a new item' do
        expect { @occurrence.update_attribute :amount, @new_amount }.to change { Item.count }.by(1)
      end

      specify 'should set the new item budget properly' do
        @occurrence.update_attribute :amount, @new_amount
        Item.last.budget_id.should == @item.budget_id
      end
      
      specify 'should set the new item category properly' do
        @occurrence.update_attribute :amount, @new_amount
        Item.last.category.should == @item.category
      end

      specify 'should set the new item amount to the new amount' do
        @occurrence.update_attribute :amount, @new_amount
        Item.last.amount.should == @new_amount
      end

      specify 'should set the new item starts_on to the occurrence date' do
        @occurrence.update_attribute :amount, @new_amount
        Item.last.starts_on.should == @occurrence.date
      end

      specify 'should associate the occurrence with the new item' do
        @occurrence.update_attribute :amount, @new_amount
        @occurrence.item.id.should == Item.last.id
        @occurrence.item_id.should == @occurrence.item.id
      end
    end # context 'and this is the second occurrence'

    context 'and this is not the first or second occurrence' do
      before(:each) do
        @occurrence = @item.occurrences.ordinal(3)
      end

      specify 'should create a new item' do
        expect { @occurrence.update_attribute :amount, @new_amount }.to change { Item.count }.by(1)
      end

      specify 'should set the old item ends_on to the occurrence before this one' do
        previous_occurrence = @item.occurrences.ordinal(@occurrence.ordinal - 1)
        @occurrence.update_attribute :amount, @new_amount
        @item.reload.ends_on.should == previous_occurrence.date
      end

      specify 'should set the new item budget properly' do
        @occurrence.update_attribute :amount, @new_amount
        Item.last.budget_id.should == @item.budget_id
      end
      
      specify 'should set the new item category properly' do
        @occurrence.update_attribute :amount, @new_amount
        Item.last.category.should == @item.category
      end

      specify 'should set the new item schedule properly' do
        @occurrence.update_attribute :amount, @new_amount
        Item.last.schedule.should == @item.schedule
      end

      specify 'should set the new item amount to the new amount' do
        @occurrence.update_attribute :amount, @new_amount
        Item.last.amount.should == @new_amount
      end

      specify 'should set the new item starts_on to the occurrence date' do
        @occurrence.update_attribute :amount, @new_amount
        Item.last.starts_on.should == @occurrence.date
      end

      specify 'should associate the occurrence with the new item' do
        @occurrence.update_attribute :amount, @new_amount
        @occurrence.item.id.should == Item.last.id
        @occurrence.item_id.should == @occurrence.item.id
      end
    end # context 'and this is not the first or second occurrence'
  end # describe 'changing item.amount when the item schedule is not once'

  describe 'deleting the occurrence' do
    context 'when item.schedule is once' do
      before(:each) do
        @item = Factory.create :item, :schedule => 'once'
        @occurrence = @item.occurrences.first
        @txn = Factory.create :transaction, :item => @item, :occurrence => @occurrence.date, :date => @occurrence.date
        @occurrence.destroy
      end

      specify 'should delete the item' do
        Item.find_by_id(@item.id).should be_nil
      end

      specify 'should make any transactions misc' do
        @txn.reload.misc?.should be_true
      end
    end # context 'when item.schedule is once'

    context 'when item.schedule is not once' do
      before(:each) do
        @item = Factory.create :item, :schedule => 'weekly', :starts_on => Date.today, :ends_on => Date.today + 4.weeks
      end

      context 'and this is the first occurrence' do
        before(:each) do
          @first_occurrence = @item.occurrences.first
          @second_occurrence = @item.occurrences.ordinal(2)
          @txn = Factory.create :transaction, :item => @item, :occurrence => @first_occurrence.date, :date => @first_occurrence.date
          @first_occurrence.destroy
        end

        specify 'should change item.starts_on to second occurrence' do
          @item.reload.starts_on.should == @second_occurrence.date
        end

        specify 'should orphan any transactions' do
          @txn.reload.orphan?.should be_true
        end
      end # context 'and this is the first occurrence'

      context 'and this is not the first occurrence' do
        before(:each) do
          @occurrence = @item.occurrences.ordinal(2)
          @txn = Factory.create :transaction, :item => @item, :occurrence => @occurrence.date, :date => @occurrence.date
          @occurrence.destroy
        end

        specify 'should add an exception for the occurrence date' do
          @item.occurrences.exists?(@occurrence.date).should_not be_true
        end

        specify 'should orphan any transactions' do
          @txn.reload.orphan?.should be_true
        end
      end # context 'and this is not the first occurrence'
    end # context 'when item.schedule is not once'
  end # describe deleting the occurrence
end
