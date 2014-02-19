require 'integration_helper'

describe 'signing up' do
  before(:each) do
    # get to the sign up form and fill it in
    # with some test data that will be used
    # in basically all the tests

    visit signup_path
    fill_in 'Email', :with => 'some.user@example.com'
    fill_in 'Password', :with => 'password'
  end

  it 'should fail without an email' do
    fill_in 'Email', :with => ''
    click_button 'Continue'
    page.should have_content("Email can't be blank")
  end

  it 'should fail with an invalid email' do
    fill_in 'Email', :with => 'invalid @ example.com'
    click_button 'Continue'
    page.should have_content('Email is not valid')
  end

  it 'should fail with an email that is already in use' do
    email = 'already.in.use@example.com'
    Factory.create :user, :email => email
    fill_in 'Email', :with => email
    click_button 'Continue'
    page.should have_content('Email has already been taken')
  end

  it 'should fail without a password' do
    fill_in 'Password', :with => ''
    click_button 'Continue'
    page.should have_content("Password can't be blank")
  end

  it 'should create a member when acceptable values are entered' do
    expect { click_button 'Continue' }.to change { User.count }.by(1)
  end
end
