require 'model_helper'

describe Occurrences do
  describe '#all' do
    it 'should return an array of Occurrence objects' do
      # item factory creates starts_on/ends_on automatically
      item = Factory.create :item, :schedule => 'monthly'
      occurrences = Occurrences.new(item).all
      occurrences.class.should == Array
      occurrences.first.class.should == Occurrence
    end

    it 'should return all occurrences up to the ending date of the schedule' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-12-31')
      occurrences = Occurrences.new(item).all
      occurrences.size.should == 12
    end

    it 'should raise an exception if there is no ending date for the schedule' do
      # IceCube will raise an error if the schedule is open-ended ... if so, should
      # use #until or #limit instead

      item = Factory.create :item, :schedule => 'monthly', :ends_on => nil
      expect { Occurrences.new(item).all }.to raise_error
    end
	end # describe '#all'

  describe '#limit' do
    it 'should return only the number requested' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-12-31')
      Occurrences.new(item).limit(7).size.should == 7
    end

    it 'should work even if the item schedule has no end date' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => nil
      Occurrences.new(item).limit(7).size.should == 7
    end

    it 'should return all occurrences when the requested number exceeds actual number' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-03-31')
      Occurrences.new(item).limit(7).size.should == 3
    end
  end # describe '#limit'

  describe '#until' do
    it 'should return all occurrences from schedule.starts_on until the date passed in' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-12-31')
      ending = Date.parse('2012-04-03')
      Occurrences.new(item).until(ending).last.date.should <= ending
    end

    it 'should accept a string representation of the date' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-12-31')
      ending = '2012-04-03'
      Occurrences.new(item).until(ending).last.date.should <= Date.parse(ending)
    end

    it 'should work even if the item schedule has no end date' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => nil
      ending = Date.parse('2012-04-03')
      Occurrences.new(item).until(ending).last.date.should <= ending
    end

    it 'should return all occurrences when the requested date is beyond the schedule ends_on' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-03-31')
      ending = Date.parse('2012-04-03')
      Occurrences.new(item).until(ending).size.should == 3
    end
  end # describe '#until'

  describe '#between' do
    it 'should return only those occurrences between two specified dates' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-12-31')
      Occurrences.new(item).between(Date.parse('2012-02-01'), Date.parse('2012-03-02')).size.should == 2
    end

    it 'should accept string representations of the dates' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-12-31')
      Occurrences.new(item).between('2012-02-01', '2012-03-02').size.should == 2
    end

    it 'should work even if the item schedule has no end date' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => nil
      Occurrences.new(item).between('2012-02-01', '2012-03-02').size.should == 2
    end

    it 'should return all occurrences when the date range bookends the schedule date range' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-03-31')
      Occurrences.new(item).between('2011-12-01', '2013-01-01').size.should == 3
    end
  end # describe '#between'

  describe '#exists?' do
    it 'should not be true if date is nil' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-12-31')
      Occurrences.new(item).exists?(nil).should_not be_true
    end

    it 'should not be true if date is empty string' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-12-31')
      Occurrences.new(item).exists?('').should_not be_true
    end

    it 'should not be true if date is not a date' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-12-31')
      Occurrences.new(item).exists?('ABCDE').should_not be_true
    end

    it 'should be true when the date is an occurrence' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-12-31')
      Occurrences.new(item).exists?(Date.parse('2012-02-01')).should be_true
    end

    it 'should not be true when the date is not an occurrence' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-12-31')
      Occurrences.new(item).exists?(Date.parse('2012-02-02')).should_not be_true
    end

    it 'should not be true when the date is an exception' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-12-31')
      date = Date.parse('2012-02-01')
      item.ice_cube_schedule.add_exception_time date.to_time
      Occurrences.new(item).exists?(date).should_not be_true
    end

    it 'should accept a string representation of the date' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-12-31')
      Occurrences.new(item).exists?('2012-02-01').should be_true
    end

    it 'should work even if the item schedule has no end date' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => nil
      Occurrences.new(item).exists?(Date.parse('2012-02-01')).should be_true
    end
  end # describe '#exists?'

  describe '#fetch' do
    it 'should return an occurrence for the given date' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-12-31')
      date = Date.parse('2012-06-01')
      Occurrences.new(item).fetch(date).date.should == date
    end

    it 'should accept a string representation of the date' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-12-31')
      date = '2012-06-01'
      Occurrences.new(item).fetch(date).date.should == Date.parse(date)
    end

    it 'should return nil if there is not an occurrence matching the date' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-12-31')
      Occurrences.new(item).fetch(Date.parse('2012-01-02')).should be_nil
    end

    it 'should return nil if the date is an exception' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-12-31')
      date = Date.parse('2012-02-01')
      item.ice_cube_schedule.add_exception_time date.to_time
      Occurrences.new(item).fetch(date).should be_nil
    end

    it 'should return nil if the date is nil' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-12-31')
      Occurrences.new(item).fetch(nil).should be_nil
    end

    it 'should return nil if the date is an empty string' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-12-31')
      Occurrences.new(item).fetch('').should be_nil
    end

    it 'should return nil if the date is not a date' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => Date.parse('2012-12-31')
      Occurrences.new(item).fetch('ABCDEF').should be_nil
    end

    it 'should work even if the item schedule has no end date' do
      item = Factory.create :item, :schedule => 'monthly', :starts_on => Date.parse('2012-01-01'), :ends_on => nil
      date = Date.parse('2012-06-01')
      Occurrences.new(item).fetch(date).date.should == date
    end
  end # describe '#fetch'

  describe '#ordinal' do
    before(:each) do
      @starts_on = Date.today.beginning_of_month
      ends_on = @starts_on + 12.months - 1.day
      @item = Factory.create :item, :schedule => 'monthly', :starts_on => @starts_on, :ends_on => ends_on
      @occurrences = Occurrences.new(@item)
    end

    it 'should return the occurrence in requested ordinal position' do
      @occurrences.ordinal(1).date.should == @starts_on
      @occurrences.ordinal(2).date.should == @starts_on + 1.month
      @occurrences.ordinal(5).date.should == @starts_on + 4.months
    end

    it 'should return nil if requested position is < 1' do
      @occurrences.ordinal(0).should be_nil
      @occurrences.ordinal(-1).should be_nil
    end

    it 'should return nil if requested position is > occurrences.size' do
      @occurrences.ordinal(13).should be_nil
    end
  end # describe '#ordinal'

  describe '#first' do
    it 'should return the first occurrence' do
      item = Factory.create :item
      Occurrences.new(item).first.first?.should be_true
    end
  end # describe '#first'
end # describe Occurrences