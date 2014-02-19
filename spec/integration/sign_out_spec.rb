require 'integration_helper'

describe 'signing out' do
  before(:each) do
    sign_in
  end

  it 'should sign the user out' do
    click_link 'Logout'
    current_path.should == root_path
  end

  it 'should prevent the user from accessing pages that require being signed in' do
    click_link 'Logout'
    visit new_budget_path
    current_path.should == login_path
  end
end