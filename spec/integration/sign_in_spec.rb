require 'integration_helper'

describe 'signing in' do
  before(:each) do
    # get to the sign in form and fill it in
    # with some test data that will be used
    # in basically all the tests

    email = 'some.user@example.com'
    password = 'password'
    @user = Factory.create :user, :email => email, :password => password

    visit login_path
    fill_in 'Email', :with => email
    fill_in 'Password', :with => password
  end

  context 'with invalid data' do
    it 'should fail without an email' do
      fill_in 'Email', :with => ''
      click_button 'Continue'
      page.should have_content(Constants::Users::UNKNOWN_EMAIL)
    end

    it 'should fail without a password' do
      fill_in 'Password', :with => ''
      click_button 'Continue'
      page.should have_content(Constants::Users::WRONG_PASSWORD)
    end

    it 'should fail with an invalid email' do
      fill_in 'Email', :with => 'invalid.email example.com'
      click_button 'Continue'
      page.should have_content(Constants::Users::UNKNOWN_EMAIL)
    end

    it 'should fail with an unknown email' do
      fill_in 'Email', :with => 'unknown.email@example.com'
      click_button 'Continue'
      page.should have_content(Constants::Users::UNKNOWN_EMAIL)
    end

    it 'should fail when password is wrong' do
      fill_in 'Password', :with => 'wrong-password'
      click_button 'Continue'
      page.should have_content(Constants::Users::WRONG_PASSWORD)
    end
  end # context 'with invalid data'

  context 'with valid data' do
    it 'should redirect to new_budget_path if a budget does not exist' do
      click_button 'Continue'
      current_path.should == new_budget_path
    end

    it 'should redirect to budget_path when a budget exists' do
      budget = Factory.create :budget, :user => @user
      click_button 'Continue'
      current_path.should == budget_path(budget)
    end
  end # context 'with valid data'
end
