require 'spec_helper'

describe Spendful::Factories::OccurrenceFactory do
  it 'should build an occurrence' do
    occurrence = OccurrenceFactory.build
    occurrence.class.name.should == 'Occurrence'
  end

  it 'should build an occurrence with custom attributes' do
    today = Date.today
    attributes = { :date => today }
    occurrence = OccurrenceFactory.build attributes
    occurrence.date.should == today
  end

  it 'should build an occurrence with an item by default' do
    occurrence = OccurrenceFactory.build
    occurrence.item_id.should_not be_nil
  end

  it 'should build an occurrence using an existing item' do
    item = ItemFactory.create :schedule => 'monthly', :starts_on => Date.today.beginning_of_year, :ends_on => Date.today.end_of_year

    # by specifying the association
    occurrence = OccurrenceFactory.build :item => item
    occurrence.item_id.should == item.id

    # by specifying the association's id
    occurrence = OccurrenceFactory.build :item_id => item.id
    occurrence.item.id.should == item.id
  end
end