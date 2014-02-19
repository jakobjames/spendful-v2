require 'spec_helper'

describe Spendful::Factories::UserFactory do
  it 'should build a valid user' do
    user = UserFactory.build
    user.class.should == User
    user.new_record?.should be_true
    user.should be_valid
  end

  it 'should build a user with custom attributes' do
    attributes = { :email => 'flibby@jibbit.net' }
    user = UserFactory.build attributes
    attributes.keys.each { |key| user.attributes[key.to_s].should == attributes[key] }
  end

  it 'should build a user with a country by default' do
    user = UserFactory.build
    user.country_id.should_not be_nil
  end

  it 'should build a user without a country' do
    # by specifying the association
    user = UserFactory.build :country => nil
    user.country_id.should be_nil

    # by specifying the association's id
    user = UserFactory.build :country_id => nil
    user.country.should be_nil
  end

  it 'should build a user using an existing country' do
    country = CountryFactory.create

    # by specifying the association
    user = UserFactory.build :country => country
    user.country_id.should == country.id

    # by specifying the association's id
    user = UserFactory.build :country_id => country.id
    user.country.id.should == country.id
  end

  it 'should create a valid user' do
    user = UserFactory.create
    user.class.should == User
    user.new_record?.should_not be_true
    user.should be_valid
  end

  it 'should create a user with custom attributes' do
    attributes = { :email => 'flibby@jibbit.net' }
    user = UserFactory.create attributes
    attributes.keys.each { |key| user.attributes[key.to_s].should == attributes[key] }
  end

  it 'should create a user with a country by default' do
    user = UserFactory.create
    user.country_id.should_not be_nil
  end

  it 'should create a user without a country' do
    # by specifying the association
    user = UserFactory.create :country => nil
    user.country_id.should be_nil

    # by specifying the association's id
    user = UserFactory.create :country_id => nil
    user.country.should be_nil
  end

  it 'should create a user using an existing country' do
    country = CountryFactory.create

    # by specifying the association
    user = UserFactory.create :country => country
    user.country_id.should == country.id

    # by specifying the association's id
    user = UserFactory.create :country_id => country.id
    user.country.id.should == country.id
  end
end