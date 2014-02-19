require 'integration_helper'

describe 'creating a new budget' do
  before(:each) do
    @user = sign_in
    visit new_budget_path

    fill_in 'Name', :with => 'A New Budget'
    fill_in 'Initial balance', :with => '1000'
  end

  it 'should require name' do
    fill_in 'Name', :with => ''
    click_button 'Continue'
    page.should have_content("Name can't be blank")
  end

  it 'should require initial balance' do
    fill_in 'Initial balance', :with => ''
    click_button 'Continue'
    page.should have_content("Initial balance can't be blank")
  end

  it 'should fail when the budget already exists' do
    budget = Factory.create :budget, :user => @user
    fill_in 'Name', :with => budget.name
    click_button 'Continue'
    page.should have_content("Name has already been taken")
  end

  it 'should create a new budget when all input is acceptable' do
    expect { click_button 'Continue' }.to change { Budget.count }.by(1)
  end

  it 'should redirect to budget_path for the new budget' do
    click_button 'Continue'
    page.current_path.should == budget_path(Budget.last)
  end
end # describe 'creating a new budget'