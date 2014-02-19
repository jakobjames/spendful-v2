require 'model_helper'

describe Country do
  it 'should have many users' do
    country = Factory.create :country
    user = Factory.create :user, :country => country
    country.users.should == [user]
  end

  describe 'code' do
    it 'should be required' do
      country = Factory.build :country, :code => nil
      country.should have_at_least(1).error_on(:code)
    end

    it 'should be unique' do
      country_1 = Factory.create :country
      country_2 = Factory.build :country, :code => country_1.code
      country_2.should have_at_least(1).error_on(:code)
    end
  end # describe 'code'

  describe 'name' do
    it 'should be required' do
      country = Factory.build :country, :name => nil
      country.should have_at_least(1).error_on(:name)
    end

    it 'should be unique' do
      country_1 = Factory.create :country
      country_2 = Factory.build :country, :name => country_1.name
      country_2.should have_at_least(1).error_on(:name)
    end
  end # describe 'name'

  describe 'currency' do
    it 'should not be required' do
      country = Factory.build :country, :currency => nil
      country.should have(:no).errors_on(:currency)
    end

    it 'should not be unique' do
      country_1 = Factory.create :country
      country_2 = Factory.build :country, :currency => country_1.currency
      country_2.should have(:no).errors_on(:currency)
    end
  end # describe 'currency'
end
