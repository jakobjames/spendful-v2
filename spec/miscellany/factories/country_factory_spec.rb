require 'spec_helper'

describe Spendful::Factories::CountryFactory do
  it 'should build a valid country' do
    country = CountryFactory.build
    country.class.should == Country
    country.new_record?.should be_true
    country.should be_valid
  end

  it 'should build a country with custom attributes' do
    attributes = { :code => 'AC', :name => 'A Country', :currency => 'ACD' }
    country = CountryFactory.build attributes
    attributes.keys.each { |key| country.attributes[key.to_s].should == attributes[key] }
  end

  it 'should create a valid country' do
    country = CountryFactory.create
    country.class.should == Country
    country.new_record?.should_not be_true
    country.should be_valid
  end

  it 'should create a country with custom attributes' do
    attributes = { :code => 'AC', :name => 'A Country', :currency => 'ACD' }
    country = CountryFactory.create attributes
    attributes.keys.each { |key| country.attributes[key.to_s].should == attributes[key] }
  end
end