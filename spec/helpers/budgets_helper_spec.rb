require 'helper_helper'

describe BudgetsHelper do
  describe '#budget?' do
    before(:each) do
      helper.stub(:params).and_return({:action => 'show'})
      budget = mock_model Budget, :new_record? => false
      assign(:budget, budget)
    end

    it 'should be true when budget has been saved and params[:action] == show' do
      helper.budget?.should be_true
    end

    it 'should not be true when @budget is nil' do
      assign(:budget, nil)
      helper.budget?.should_not be_true
    end

    it 'should not be true when @budget is not yet saved' do
      budget = mock_model Budget, :new_record? => true
      assign(:budget, budget)
      helper.budget?.should_not be_true
    end

    it 'should not be true when params[:action] != show' do
      helper.stub(:params).and_return({:action => 'new'})
      helper.budget?.should_not be_true
    end
  end # describe '#budget?'

  describe '#budgets?' do
    before(:each) do
      @budgets = mock 'budgets'
      user = mock_model User, :budgets => @budgets
      helper.stub(:current_user).and_return(user)
    end

    it 'should be true when the current user has budgets' do
      @budgets.stub(:any?).and_return(true)
      helper.budgets?.should be_true
    end

    it 'should not be true when the current user does not have budgets' do
      @budgets.stub(:any?).and_return(false)
      helper.budgets?.should_not be_true
    end
  end # describe '#budgets?'
end # describe BudgetsHelper
