require 'spec_helper'

describe Spendful::Factories::TransactionFactory do
  it 'should build a valid transaction' do
    transaction = TransactionFactory.build
    transaction.class.should == Transaction
    transaction.new_record?.should be_true
    transaction.should be_valid
  end

  it 'should build a transaction with custom attributes' do
    attributes = { :item => nil, :category => 'income', :description => 'A Transaction', :amount => 12345, :date => Date.today }
    transaction = TransactionFactory.build attributes
    attributes.keys.each { |key| transaction.attributes[key.to_s].should == attributes[key] }
  end

  it 'should build a transaction with a budget by default' do
    transaction = TransactionFactory.build
    transaction.budget_id.should_not be_nil
  end

  it 'should build a transaction using an existing budget (using it for the item)' do
    budget = BudgetFactory.create

    # by specifying the association
    transaction = TransactionFactory.build :budget => budget
    transaction.budget_id.should == budget.id
    transaction.item.budget_id.should == budget.id

    # by specifying the association's id
    transaction = TransactionFactory.build :budget_id => budget.id
    transaction.budget.id.should == budget.id
    transaction.item.budget.id.should == budget.id
  end

  it 'should not build a transaction without a budget if no item is provided' do
    # by specifying the association
    transaction = TransactionFactory.build :budget => nil, :item => nil
    transaction.budget_id.should_not be_nil

    # by specifying the association's id
    transaction = TransactionFactory.build :budget_id => nil, :item => nil
    transaction.budget.id.should_not be_nil
  end
  
  it 'should build a transaction with an item by default' do
    transaction = TransactionFactory.build
    transaction.item_id.should_not be_nil
  end

  it 'should build a transaction without an item' do
    # by specifying the association
    transaction = TransactionFactory.build :item => nil
    transaction.item_id.should be_nil

    # by specifying the association's id
    transaction = TransactionFactory.build :item_id => nil
    transaction.item.should be_nil
  end

  it 'should build a transaction using an existing item (and associated budget)' do
    item = ItemFactory.create :schedule => 'monthly', :starts_on => Date.today.beginning_of_year, :ends_on => Date.today.end_of_year

    # by specifying the association
    transaction = TransactionFactory.build :item => item
    transaction.item_id.should == item.id
    transaction.budget_id.should == item.budget_id

    # by specifying the association's id
    transaction = TransactionFactory.build :item_id => item.id
    transaction.item.id.should == item.id
    transaction.budget.id.should == item.budget.id
  end

  it 'should create a valid transaction' do
    transaction = TransactionFactory.create
    transaction.class.should == Transaction
    transaction.new_record?.should_not be_true
    transaction.should be_valid
  end

  it 'should create a transaction with custom attributes' do
    # this one is a little trickier ... since some attributes are validated conditionally based on the item,
    # we have to be careful that we don't pass in attributes that will fail validation (this is trying to create
    # an object)
    attributes = { :item => nil, :category => 'income', :description => 'A Transaction', :amount => 12345, :date => Date.today }
    transaction = TransactionFactory.create attributes
    attributes.keys.each { |key| transaction.attributes[key.to_s].should == attributes[key] }
  end

  it 'should create a transaction with a budget by default' do
    transaction = TransactionFactory.create
    transaction.budget_id.should_not be_nil
  end

  it 'should create a transaction using an existing budget' do
    budget = BudgetFactory.create

    # by specifying the association
    transaction = TransactionFactory.create :budget => budget
    transaction.budget_id.should == budget.id

    # by specifying the association's id
    transaction = TransactionFactory.create :budget_id => budget.id
    transaction.budget.id.should == budget.id
  end

  it 'should create a transaction with an item by default' do
    transaction = TransactionFactory.create
    transaction.item_id.should_not be_nil
  end

  it 'should create a transaction without an item' do
    # by specifying the association
    transaction = TransactionFactory.create :item => nil
    transaction.item_id.should be_nil

    # by specifying the association's id
    transaction = TransactionFactory.create :item_id => nil
    transaction.item.should be_nil
  end

  it 'should create a transaction using an existing item (and associated budget)' do
    item = ItemFactory.create :schedule => 'monthly', :starts_on => Date.today.beginning_of_year, :ends_on => Date.today.end_of_year

    # by specifying the association
    transaction = TransactionFactory.create :item => item
    transaction.item_id.should == item.id
    transaction.budget_id.should == item.budget_id

    # by specifying the association's id
    transaction = TransactionFactory.create :item_id => item.id
    transaction.item.id.should == item.id
    transaction.budget.id.should == item.budget.id
  end
end