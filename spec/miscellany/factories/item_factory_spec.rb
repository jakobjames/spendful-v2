require 'spec_helper'

describe Spendful::Factories::ItemFactory do
  it 'should build a valid item' do
    item = ItemFactory.build
    item.class.should == Item
    item.new_record?.should be_true
    item.should be_valid
  end

  it 'should build an item with custom attributes' do
    attributes = { :category => 'income', :name => 'An Item', :amount => 12345, :schedule => 'fortnightly', :starts_on => Date.today, :ends_on => Date.today + 2.weeks }
    item = ItemFactory.build attributes
    attributes.keys.each { |key| item.attributes[key.to_s].should == attributes[key] }
  end

  it 'should build an item with a budget by default' do
    item = ItemFactory.build
    item.budget_id.should_not be_nil
  end

  it 'should not build an item without a budget' do
    # by specifying the association
    item = ItemFactory.build :budget => nil
    item.budget_id.should_not be_nil

    # by specifying the association's id
    item = ItemFactory.build :budget_id => nil
    item.budget.should_not be_nil
  end

  it 'should build an item using an existing budget' do
    budget = BudgetFactory.create

    # by specifying the association
    item = ItemFactory.build :budget => budget
    item.budget_id.should == budget.id

    # by specifying the association's id
    item = ItemFactory.build :budget_id => budget.id
    item.budget.id.should == budget.id
  end

  it 'should create a valid item' do
    item = ItemFactory.create
    item.class.should == Item
    item.new_record?.should_not be_true
    item.should be_valid
  end

  it 'should create an item with custom attributes' do
    attributes = { :category => 'income', :name => 'An Item', :amount => 12345, :schedule => 'fortnightly', :starts_on => Date.today, :ends_on => Date.today + 2.weeks }
    item = ItemFactory.create attributes
    attributes.keys.each { |key| item.attributes[key.to_s].should == attributes[key] }
  end

  it 'should create an item with a budget by default' do
    item = ItemFactory.create
    item.budget_id.should_not be_nil
  end

  # there's no need to test creating an item without a budget
  # because budget_id is required on item so the object won't
  # pass validation and will not be saved

  it 'should create an item using an existing budget' do
    budget = BudgetFactory.create

    # by specifying the association
    item = ItemFactory.create :budget => budget
    item.budget_id.should == budget.id

    # by specifying the association's id
    item = ItemFactory.create :budget_id => budget.id
    item.budget.id.should == budget.id
  end
end