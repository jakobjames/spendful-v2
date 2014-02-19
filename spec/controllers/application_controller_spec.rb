require 'controller_helper'

describe ApplicationController do
  describe 'authenticate_user' do
    before(:each) do
      controller.stub(:logged_in?)
      controller.stub(:redirect_to)
    end

    it 'should check to see if the user is logged in' do
      controller.should_receive(:logged_in?)
      controller.authenticate_user
    end

    context 'when the user is not logged in' do
      before(:each) do
        controller.stub(:logged_in?).and_return(false)
      end

      it "should set flash[:notice] to #{Constants::Users::PLEASE_LOG_IN}" do
        controller.authenticate_user
        flash[:notice].should == Constants::Users::PLEASE_LOG_IN
      end

      it 'should redirect to login_path' do
        controller.should_receive(:redirect_to).with(login_path)
        controller.authenticate_user
      end
    end # context 'when the user is not logged in'

    context 'when the user is logged in' do
      before(:each) do
        controller.stub(:logged_in?).and_return(true)
      end

      it 'should not set flash[:notice]' do
        controller.authenticate_user
        flash[:notice].should be_nil
      end

      it 'should not redirect' do
        controller.should_not_receive(:redirect_to)
        controller.authenticate_user
      end
    end # context 'when the user is logged in'
  end # describe 'authenticate_user'
end