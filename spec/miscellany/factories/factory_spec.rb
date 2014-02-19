require 'spec_helper'

describe Spendful::Factories::Factory do
  # ---------- Country ----------

  it 'should build a country' do
    CountryFactory.should_receive :build
    Factory.build :country
  end

  it 'should build a country with attributes' do
    attributes = { }
    CountryFactory.should_receive(:build).with(attributes)
    Factory.build :country, attributes
  end

  it 'should create a country' do
    CountryFactory.should_receive :create
    Factory.create :country
  end

  it 'should create a country with attributes' do
    attributes = { }
    CountryFactory.should_receive(:create).with(attributes)
    Factory.create :country, attributes
  end

  # ---------- User ----------

  it 'should build a user' do
    UserFactory.should_receive :build
    Factory.build :user
  end

  it 'should build a user with attributes' do
    attributes = { }
    UserFactory.should_receive(:build).with(attributes)
    Factory.build :user, attributes
  end

  it 'should create a user' do
    UserFactory.should_receive :create
    Factory.create :user
  end

  it 'should create a user with attributes' do
    attributes = { }
    UserFactory.should_receive(:create).with(attributes)
    Factory.create :user, attributes
  end

  # ---------- Budget ----------

  it 'should build a budget' do
    BudgetFactory.should_receive :build
    Factory.build :budget
  end

  it 'should build a budget with attributes' do
    attributes = { }
    BudgetFactory.should_receive(:build).with(attributes)
    Factory.build :budget, attributes
  end

  it 'should create a budget' do
    BudgetFactory.should_receive :create
    Factory.create :budget
  end

  it 'should create a budget with attributes' do
    attributes = { }
    BudgetFactory.should_receive(:create).with(attributes)
    Factory.create :budget, attributes
  end

  # ---------- Item ----------

  it 'should build an item' do
    ItemFactory.should_receive :build
    Factory.build :item
  end

  it 'should build an item with attributes' do
    attributes = { }
    ItemFactory.should_receive(:build).with(attributes)
    Factory.build :item, attributes
  end

  it 'should create an item' do
    ItemFactory.should_receive :create
    Factory.create :item
  end

  it 'should create an item with attributes' do
    attributes = { }
    ItemFactory.should_receive(:create).with(attributes)
    Factory.create :item, attributes
  end

  # ---------- Occurrence ----------

  it 'should build an occurrence' do
    OccurrenceFactory.should_receive :build
    Factory.build :occurrence
  end

  it 'should build an occurrence with attributes' do
    attributes = { }
    OccurrenceFactory.should_receive(:build).with(attributes)
    Factory.build :occurrence, attributes
  end

  # ---------- Transaction ----------

  it 'should build a transaction' do
    TransactionFactory.should_receive :build
    Factory.build :transaction
  end

  it 'should build a transaction with attributes' do
    attributes = { }
    TransactionFactory.should_receive(:build).with(attributes)
    Factory.build :transaction, attributes
  end

  it 'should create a transaction' do
    TransactionFactory.should_receive :create
    Factory.create :transaction
  end

  it 'should create a transaction with attributes' do
    attributes = { }
    TransactionFactory.should_receive(:create).with(attributes)
    Factory.create :transaction, attributes
  end

  # ---------- Subscription ----------

  it 'should build a subscription' do
    SubscriptionFactory.should_receive :build
    Factory.build :subscription
  end

  it 'should build a subscription with attributes' do
    attributes = { }
    SubscriptionFactory.should_receive(:build).with(attributes)
    Factory.build :subscription, attributes
  end

  it 'should create a subscription' do
    SubscriptionFactory.should_receive :create
    Factory.create :subscription
  end

  it 'should create a subscription with attributes' do
    attributes = { }
    SubscriptionFactory.should_receive(:create).with(attributes)
    Factory.create :subscription, attributes
  end

  # ---------- Payment ----------

  it 'should build a payment' do
    PaymentFactory.should_receive :build
    Factory.build :payment
  end

  it 'should build a payment with attributes' do
    attributes = { }
    PaymentFactory.should_receive(:build).with(attributes)
    Factory.build :payment, attributes
  end

  it 'should create a payment' do
    PaymentFactory.should_receive :create
    Factory.create :payment
  end

  it 'should create a payment with attributes' do
    attributes = { }
    PaymentFactory.should_receive(:create).with(attributes)
    Factory.create :payment, attributes
  end
end