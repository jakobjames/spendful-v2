require 'controller_helper'

describe BudgetsController do
  before(:each) do
    @user = mock_model User
    controller.stub(:logged_in?).and_return(true)
    controller.stub(:current_user).and_return(@user)
  end

  describe 'get index' do
    it 'should redirect to budget_path for the first budget when current user has budgets' do
      budget = mock_model Budget, :to_param => 'some-slug'
      budgets = mock 'budgets'
      budgets.stub(:any?).and_return(true)
      budgets.stub(:first).and_return(budget)
      @user.stub(:budgets).and_return(budgets)

      get :index
      response.should redirect_to(budget_path(budget))
    end

    it 'should redirect to new_budget_path when current user does not have budgets' do
      budgets = mock 'budgets'
      budgets.stub(:any?).and_return(false)
      @user.stub(:budgets).and_return(budgets)

      get :index
      response.should redirect_to(new_budget_path)
    end
  end # describe 'get index'

  describe 'get show' do
    before(:each) do
      @budgets = mock 'budgets'
      @user.stub(:budgets).and_return(@budgets)
    end

    context 'when the budget exists' do
      before(:each) do
        budget = mock_model Budget
        @budgets.stub(:find_by_slug).and_return(budget)
        get :show, :id => '1'
      end

      it 'should assign @budget' do
        assigns(:budget).should_not be_nil
      end

      it 'should render the show template' do
        response.should render_template(:show)
      end
    end # context 'when the budget exists'

    context 'when the budget does not exist' do
      before(:each) do
        @budgets.stub(:find_by_slug).and_return(nil)
        get :show, :id => '1'
      end

      it 'should not assign @budget' do
        assigns(:budget).should be_nil
      end

      it 'should redirect to an error page' do
        response.should redirect_to(not_found_path)
      end
    end # context 'when the budget does not exist'
  end # describe 'get show'

  describe 'get new' do
    before(:each) do
      budget = mock_model(Budget).as_new_record
      Budget.stub(:new).and_return(budget)
    end

    it 'should make a new Budget' do
      Budget.should_receive(:new)
      get :new
    end

    it 'should assign to @budget' do
      get :new
      assigns(:budget).should_not be_nil
    end

    it 'should render the new template' do
      get :new
      response.should render_template(:new)
    end
  end # describe 'get new'

  describe 'post create' do
    before(:each) do
      @budget = mock_model(Budget, :to_param => 'some-slug').as_new_record
      @budget.stub(:user_id=)
      Budget.stub(:new).and_return(@budget)
    end

    context 'when data is valid' do
      before(:each) do
        @budget.stub(:save).and_return(true)
        post :create, {}
      end

      it "should set flash[:notice] to '#{Constants::Budgets::CREATED_MESSAGE}'" do
        flash[:notice].should == Constants::Budgets::CREATED_MESSAGE
      end

      it 'should redirect_to to the budget' do
        response.should redirect_to(budget_path(@budget))
      end
    end # context 'when data is valid'

    context 'when data is not valid' do
      before(:each) do
        @budget.stub(:save).and_return(false)
        post :create, {}
      end

      it 'should assign @budget' do
        assigns(:budget).should_not be_nil
      end

      it 'should render the new template' do
        response.should render_template(:new)
      end
    end # context 'when data is not valid'
  end # describe 'post create'

  describe 'get edit' do
    before(:each) do
      @budgets = mock 'budgets'
      @budgets.stub(:find_by_slug)
      @user.stub(:budgets).and_return(@budgets)
      @params = {:id => '1'}
    end

    it 'should look for the budget' do
      @budgets.should_receive(:find_by_slug)
      get :edit, @params
    end

    context 'when the budget exists' do
      before(:each) do
        budget = mock_model Budget
        @budgets.stub(:find_by_slug).and_return(budget)
        get :edit, @params
      end

      it 'should assign @budget' do
        assigns(:budget).should_not be_nil
      end

      it 'should render the edit template' do
        response.should render_template(:edit)
      end
    end # context 'when the budget exists'

    context 'when the budget does not exist' do
      before(:each) do
        @budgets.stub(:find_by_slug).and_return(nil)
        get :edit, @params
      end

      it 'should not assign @budget' do
        assigns(:budget).should be_nil
      end

      it 'should redirect to an error page' do
        response.should redirect_to(not_found_path)
      end
    end # context 'when the budget does not exist'
  end # describe 'get edit'

  describe 'put update' do
    before(:each) do
      @budget = mock_model Budget, :to_param => 'some-slug'
      @budget.stub(:update_attributes).and_return(true)
      @budgets = mock 'budgets'
      @budgets.stub(:find_by_slug).and_return(@budget)
      @user.stub(:budgets).and_return(@budgets)
      @params = {:id => '1'}
    end

    it 'should look for the budget' do
      @budgets.should_receive(:find_by_slug)
      put :update, @params
    end

    context 'when the budget exists' do
      context 'and the data is valid' do
        before(:each) do
          # Already stubbing @budget.update_attributes to return true
          put :update, @params
        end

        it "should set flash[:notice] to '#{Constants::Budgets::UPDATED_MESSAGE}'" do
          flash[:notice].should == Constants::Budgets::UPDATED_MESSAGE
        end

        it 'should redirect to budget_path' do
          response.should redirect_to(budget_path(@budget))
        end
      end # context 'and the data is valid'

      context 'and the data is not valid' do
        before(:each) do
          @budget.stub(:update_attributes).and_return(false)
          put :update, @params
        end

        it 'should assign @budget' do
          assigns(:budget).should_not be_nil
        end

        it 'should render the edit template' do
          response.should render_template(:edit)
        end
      end # context 'and the data is not valid'
    end # context 'when the budget exists'

    context 'when the budget does not exist' do
      before(:each) do
        @budgets.stub(:find_by_slug).and_return(nil)
        put :update, @params
      end

      it 'should not assign @budget' do
        assigns(:budget).should be_nil
      end

      it 'should redirect to an error page' do
        response.should redirect_to(not_found_path)
      end
    end # context 'when the budget does not exist'
  end # describe 'put update'
end