require 'integration_helper'

describe 'showing a budget' do
  before(:each) do
    @today = Time.parse('2012-07-16')
    Timecop.freeze @today

    @user = sign_in
    @budget = Factory.create :budget, :user => @user, :name => 'My Budget', :initial_balance => 5000
    item = Factory.create :item, :budget => @budget, :category => 'income', :amount => 500, :starts_on => @today.beginning_of_month + 1.day, :schedule => 'fortnightly'

    visit budget_path(@budget)
  end

  describe '- dates in aside' do
    include ActionView::Helpers::TextHelper

    it 'should include today' do
      within('div.balance.today') do
        page.should have_content(@today.strftime(Constants::Formats::SHORT_DATE).squish)
      end
    end

    it 'should include beginning of month' do
      days = @today.day - @today.beginning_of_month.day
      within('div.balance.beginning-of-month') do
        page.should have_content("Started #{pluralize(days, 'day')} ago")
      end
    end

    it 'should include end of month' do
      days = @today.end_of_month.day - @today.day
      within('div.balance.end-of-month') do
        page.should have_content("Ending in #{pluralize(days, 'day')}")
      end
    end
  end # describe '- dates in aside'

  describe '- balances in aside' do
    it 'should include as of today' do
      within('div.balance.today') do
        page.should have_content(@budget.balance(@today.to_date))
      end
    end

    it 'should include as of the beginning of the month' do
      within('div.balance.beginning-of-month') do
        page.should have_content(@budget.balance(@today.beginning_of_month.to_date))
      end
    end

    it 'should include as of the end of the month' do
      within('div.balance.end-of-month') do
        page.should have_content(@budget.balance(@today.end_of_month.to_date))
      end
    end
  end # describe '- balances in aside'
end # describe 'showing a budget'