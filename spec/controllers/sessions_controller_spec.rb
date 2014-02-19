require 'controller_helper'

describe SessionsController do
  describe 'get new' do
    it 'should check to see if user is logged in' do
      @controller.should_receive(:logged_in?)
      get :new
    end

    context 'when user is signed in' do
      it 'should redirect to budgets_path' do
        @controller.stub(:logged_in?).and_return(true)
        get :new
        response.should redirect_to(budgets_path)
      end
    end # context 'when user is signed in'

    context 'when user is not signed in' do
      it 'should render the new template' do
        @controller.stub(:logged_in?).and_return(false)
        get :new
        response.should render_template(:new)
      end
    end # context 'when user is not signed in'
  end # describe 'get new'

  describe 'post create' do
    before(:each) do
      @user = mock_model User, :uuid => '12345'
      @message = 'does not matter'
      controller.stub(:current_user=)

      @email = 'some.email@example.com'
      @password = 'some.password'
    end

    it 'should authenticate the credentials' do
      User.should_receive(:authenticate).with(@email, @password)
      post :create, { :email => @email, :password => @password }
    end

    context 'when valid credentials given' do
      before(:each) do
        User.stub(:authenticate).and_return([@user, @message])
        @controller.stub(:current_user=)
        post :create, { :email => @email, :password => @password }
      end

      it 'should set the current user to the returned user' do
        @controller.should_receive(:current_user=).with(@user)
        post :create, { :email => @email, :password => @password }
      end

      it 'should set flash[:notice] to the returned message' do
        flash[:notice].should == @message
      end

      it 'should redirect to budgets_path' do
        response.should redirect_to(budgets_path)
      end
    end # context 'when valid credentials given'

    context 'when invalid credentials given' do
      before(:each) do
        User.stub(:authenticate).and_return([nil, @message])
      end

      it 'should not set the current user' do
        @controller.should_not_receive(:current_user=)
        post :create, { :email => @email, :password => @password }
      end

      it 'should set flash[:alert] to the returned message' do
        post :create, { :email => @email, :password => @password }
        flash[:alert].should == @message
      end

      it 'should render the new template' do
        post :create, { :email => @email, :password => @password }
        response.should render_template(:new)
      end
    end # context 'when invalid credentials given'
  end # describe 'post create'

  describe 'get destroy' do
    before(:each) do
      # if the user is not logged in, destroy action will never
      # be called, so we have to pretend user is logged in
      @controller.stub(:authenticate_user).and_return(true)
      @controller.stub(:reset_current_user)
    end

    it 'should reset the current user' do
      @controller.should_receive(:reset_current_user)
      get :destroy
    end

    it 'should set flash[:notice] to the appropriate message' do
      get :destroy
      flash[:notice].should == Constants::Users::LOGOUT_SUCCESSFUL
    end

    it 'should redirect to root_path' do
      get :destroy
      response.should redirect_to(root_path)
    end
  end # describe 'get destroy'
end