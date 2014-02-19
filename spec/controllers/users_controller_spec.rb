require 'controller_helper'

describe UsersController do
  describe 'get new' do
    context 'when user is logged in' do
      before(:each) do
        controller.stub(:logged_in?).and_return(true)
        get :new
      end

      it 'should redirect to budgets_path' do
        response.should redirect_to(budgets_path)
      end

      it 'should not create a new User' do
        User.should_not_receive(:new)
        get :new
      end

      it 'should not assign @user' do
        get :new
        assigns.should_not have_key(:user)
      end

      it 'should not render the new template' do
        response.should_not render_template(:new)
      end
    end # context 'when user is logged in'

    context 'when user is not logged in' do
      before(:each) do
        controller.stub(:logged_in?).and_return(false)
        user = mock_model User
        User.stub(:new).and_return(user)
      end

      it 'should not redirect to budgets path' do
        get :new
        response.should_not redirect_to(budgets_path)
      end

      it 'should create new User' do
        User.should_receive(:new)
        get :new
      end

      it 'should set @user' do
        get :new
        assigns(:user).should_not be_nil
      end

      it 'should render the new template' do
        get :new
        response.should render_template(:new)
      end
    end # context 'when user is not logged in'
  end

  describe 'post create' do
    before(:each) do
      @user = mock_model User
      @user.stub(:save)
      User.stub(:new).and_return(@user)
    end

    it 'should create a new User' do
      User.should_receive(:new)
      post :create, {}
    end

    it 'should try to save the user' do
      @user.should_receive(:save)
      post :create, {}
    end

    context 'with valid data' do
      before(:each) do
        @user.stub(:save).and_return(true)
      end

      it 'should set the current user' do
        controller.should_receive(:current_user=)
        post :create, {}
      end

      it "should set flash[:notice] to '#{Constants::Users::WELCOME_MESSAGE}'" do
        post :create, {}
        flash[:notice].should == Constants::Users::WELCOME_MESSAGE
      end

      it 'should redirect to budgets_path' do
        post :create, {}
        response.should redirect_to(budgets_path)
      end
    end # context 'with valid data'

    context 'with invalid data' do
      before(:each) do
        @user.stub(:save).and_return(false)
      end

      it 'should not set the current user' do
        controller.should_not_receive(:current_user=)
        post :create, {}
      end

      it 'should not set flash[:notice]' do
        post :create, {}
        flash[:notice].should be_nil
      end

      it 'should render the new template' do
        post :create, {}
        response.should render_template(:new)
      end
    end # context 'with invalid data'
  end # describe 'post create'

  describe 'get edit' do
    before(:each) do
      @user = mock_model User
      controller.stub(:current_user).and_return(@user)
      controller.stub(:logged_in?).and_return(true)
    end

    it 'should get the current user' do
      controller.should_receive(:current_user)
      get :edit
    end

    it 'should set @user to the current user' do
      get :edit
      assigns(:user).should == @user
    end

    it 'should render the edit template' do
      get :edit
      response.should render_template(:edit)
    end
  end # describe 'get edit'

  describe 'put update' do
    before(:each) do
      @params = { :id => 1 }
      @user = mock_model User
      @user.stub(:update_attributes)
      controller.stub(:current_user).and_return(@user)
      controller.stub(:logged_in?).and_return(true)
    end

    it 'should get the current user' do
      controller.should_receive(:current_user)
      put :update, @params
    end

    it 'should set @user to the current user' do
      put :update, @params
      assigns(:user).should == @user
    end

    it 'should try to update attributes' do
      @user.should_receive(:update_attributes)
      put :update, @params
    end

    context 'with valid data' do
      before(:each) do
        @user.stub(:update_attributes).and_return(true)
      end

      it 'should update the current user' do
        controller.should_receive(:current_user=)
        put :update, @params
      end

      it "should set flash[:notice] to '#{Constants::Users::DETAILS_UPDATED}'" do
        put :update, @params
        flash[:notice].should == Constants::Users::DETAILS_UPDATED
      end

      it 'should redirect to account_path' do
        put :update, @params
        response.should redirect_to(account_path)
      end
    end # context 'with valid data'

    context 'with invalid data' do
      before(:each) do
        @user.stub(:update_attributes).and_return(false)
      end

      it 'should not update the current user' do
        controller.should_not_receive(:current_user=)
        put :update, @params
      end

      it 'should not set flash[:notice]' do
        put :update, @params
        flash[:notice].should be_nil
      end

      it 'should render the edit template' do
        put :update, @params
        response.should render_template(:edit)
      end
    end # context 'with invalid data'
  end # describe 'put update'

  describe 'delete destroy' do
    before(:each) do
      @params = { :id => 1 }
      @user = mock_model User
      @user.stub(:destroy)
      controller.stub(:current_user).and_return(@user)
      controller.stub(:logged_in?).and_return(true)
    end

    it 'should get the current user' do
      controller.should_receive(:current_user)
      delete :destroy, @params
    end

    it 'should destroy the user' do
      @user.should_receive(:destroy)
      delete :destroy, @params
    end

    it 'should reset the current user' do
      controller.should_receive(:reset_current_user)
      delete :destroy, @params
    end

    it "should set flash[:notice] to '#{Constants::Users::ACCOUNT_DELETED}'" do
      delete :destroy, @params
      flash[:notice].should == Constants::Users::ACCOUNT_DELETED
    end

    it 'should redirect to root_path' do
      delete :destroy, @params
      response.should redirect_to(root_path)
    end
  end # describe 'delete destroy'
end