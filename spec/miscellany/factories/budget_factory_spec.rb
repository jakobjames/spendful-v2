require 'spec_helper'

describe Spendful::Factories::BudgetFactory do
  it 'should build a valid budget' do
    budget = BudgetFactory.build
    budget.class.should == Budget
    budget.new_record?.should be_true
    budget.should be_valid
  end

  it 'should build a budget with custom attributes' do
    attributes = { :name => 'A Budget', :initial_balance => 12345, :currency => 'ABC' }
    budget = BudgetFactory.build attributes
    attributes.keys.each { |key| budget.attributes[key.to_s].should == attributes[key] }
  end

  it 'should build a budget with a user by default' do
    budget = BudgetFactory.build
    budget.user_id.should_not be_nil
  end

  it 'should not build a budget without a user' do
    # by specifying the association
    budget = BudgetFactory.build :user => nil
    budget.user_id.should_not be_nil

    # by specifying the association's id
    budget = BudgetFactory.build :user_id => nil
    budget.user.should_not be_nil
  end

  it 'should build a budget using an existing user' do
    user = UserFactory.create

    # by specifying the association
    budget = BudgetFactory.build :user => user
    budget.user_id.should == user.id

    # by specifying the association's id
    budget = BudgetFactory.build :user_id => user.id
    budget.user.id.should == user.id
  end

  it 'should create a valid budget' do
    budget = BudgetFactory.create
    budget.class.should == Budget
    budget.new_record?.should_not be_true
    budget.should be_valid
  end

  it 'should create a budget with custom attributes' do
    attributes = { :name => 'A Budget', :initial_balance => 12345, :currency => 'ABC' }
    budget = BudgetFactory.create attributes
    attributes.keys.each { |key| budget.attributes[key.to_s].should == attributes[key] }
  end

  it 'should create a budget with a user by default' do
    budget = BudgetFactory.create
    budget.user_id.should_not be_nil
  end

  # there's no need to test creating a budget without a user
  # because user_id is required on budget so the object won't
  # pass validation and will not be saved
  
  it 'should create a budget using an existing user' do
    user = UserFactory.create

    # by specifying the association
    budget = BudgetFactory.create :user => user
    budget.user_id.should == user.id

    # by specifying the association's id
    budget = BudgetFactory.create :user_id => user.id
    budget.user.id.should == user.id
  end
end