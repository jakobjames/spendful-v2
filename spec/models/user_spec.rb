require 'model_helper'

describe User do

  it 'should have many budgets' do
    user = Factory.create :user
    budget = Factory.create :budget, :user => user
    user.budgets.should == [budget]
  end

  it 'should sort budgets by updated_at descending (most recent first)' do
    user = Factory.create :user
    budget_1 = Factory.create :budget, :user => user
    budget_2 = Factory.create :budget, :user => user
    budget_1.update_attribute :name, budget_1.name.reverse
    user.budgets.first.id.should == budget_1.id
    budget_2.update_attribute :name, budget_2.name.reverse
    user.budgets.first.id.should == budget_2.id
  end

  it 'should destroy budgets when self is destroyed' do
    budget = Factory.create :budget
    budget.user.destroy
    Budget.count.should == 0
  end

  it 'should have many subscriptions' do
    user = Factory.create :user
    subscription = Factory.create :subscription, :user => user
    user.subscriptions.should == [subscription]
  end

  it 'should destroy subscriptions when self is destroyed' do
    user = Factory.create :user
    Factory.create :subscription, :user => user
    expect { user.destroy }.to change { Subscription.count }.by(-1)
  end

  describe '#current_subscription' do
    before(:each) do
      @user = Factory.create :user
      Factory.create :subscription, :user => @user, :payment_plan => 'monthly', :started_on => Date.today - 10.days, :expires_on => Date.today - 9.days
      @current_subscription = Factory.create :subscription, :user => @user, :started_on => Date.today - 6.days
    end

    it 'should return the current subscription when not pending' do
      @user.current_subscription.should == @current_subscription
    end

    it 'should return the current subscription when pending' do
      @current_subscription.update_attributes :started_on => nil, :expires_on => nil
      @user.current_subscription.should == @current_subscription
    end
  end # describe '#current_subscription'

  describe '#pending_subscription' do
    before(:each) do
      @user = Factory.create :user
      Factory.create :subscription, :user => @user, :payment_plan => 'monthly', :started_on => Date.today - 10.days, :expires_on => Date.today - 9.days
      @current_subscription = Factory.create :subscription, :user => @user, :started_on => nil
    end

    it 'should return the current subscription when pending' do
      @user.pending_subscription.should == @current_subscription
    end

    it 'should not return the current subscription when not pending' do
      @current_subscription.update_attributes :started_on => Date.today
      @user.pending_subscription.should be_nil
    end
  end # describe '#pending_subscription'

  describe '#pending?' do
    before(:each) do
      @user = Factory.create :user
    end

    it 'should return true when there is a pending subscription' do
      @user.stub(:pending_subscription).and_return(mock_model(Subscription))
      @user.pending?.should be_true
    end

    it 'should not return true when there is not a pending subscription' do
      @user.stub(:pending_subscription).and_return(nil)
      @user.pending?.should_not be_true
    end
  end # describe '#pending?'

  describe '#pend!' do
    before(:each) do
      @user = Factory.create :user
      @payment_plan = 'monthly'
    end

    it 'should require a payment plan' do
      expect { @user.pend! }.to raise_exception
    end

    it 'should do nothing if there is already a current subscription' do
      Factory.create :subscription, :user => @user, :started_on => Date.today
      expect { @user.pend! @payment_plan }.to_not change { @user.subscriptions.size }
    end

    it 'should do nothing if there is already a pending subscription' do
      Factory.create :subscription, :user => @user, :started_on => nil
      expect { @user.pend! @payment_plan }.to_not change { @user.subscriptions.size }
    end

    it 'should create a pending subscription' do
      @user.pend! @payment_plan
      subscription = @user.subscriptions.first
      subscription.should_not be_nil
      subscription.subscription_type.should == 'premium'
      subscription.payment_plan.should == @payment_plan
    end
  end # describe '#pend!'

  describe '#free?' do
    before(:each) do
      @user = Factory.create :user
    end

    it 'should be true if there is not a current subscription' do
      # notice no subscription is created
      @user.free?.should be_true
    end

    it 'should be true if there is a current subscription that is pending' do
      Factory.create :subscription, :user => @user, :started_on => nil
      @user.free?.should be_true
    end

    it 'should not be true if there is a current subscription that is not pending' do
      Factory.create :subscription, :user => @user, :started_on => Date.today - 10.days
      @user.free?.should_not be_true
    end
  end # describe '#free?'

  describe '#premium?' do
    before(:each) do
      @user = Factory.create :user
    end

    it 'should not be true if there is not a current subscription' do
      # notice no subscription is created
      @user.premium?.should_not be_true
    end

    it 'should not be true if there is a current subscription that is pending' do
      Factory.create :subscription, :user => @user, :started_on => nil
      @user.premium?.should_not be_true
    end

    it 'should be true if there is a current subscription that is not pending' do
      Factory.create :subscription, :user => @user, :started_on => Date.today - 10.days
      @user.premium?.should be_true
    end
  end

  describe '#current?' do
    it 'should be an alias of #premium?' do
      user = User.new
      user.method(:current?).should == user.method(:premium?)
    end
  end # describe '#current?'

  describe 'email' do
    it 'should be required' do
      user = Factory.build :user, :email => nil
      user.should have_at_least(1).error_on(:email)
    end

    it 'should be unique' do
      user_1 = Factory.create :user
      user_2 = Factory.build :user, :email => user_1.email
      user_2.should have_at_least(1).error_on(:email)
    end

    it 'should be downcased' do
      email = 'SOME.USER@EXAMPLE.COM'
      user = Factory.create :user, :email => email
      user.email.should == email.downcase

      # now make sure it works when updated
      user.update_attributes :email => email
      user.email.should == email.downcase
    end

    it 'should accept valid emails' do
      valid_emails = [
        'user@example.com',
        'another.user@example.com',
        'a.user.with.a.long.name@dept.example.com',
        'user+something@example.com',
        'user+something.else@example.com',
        'user+something_else@example.com',
        'user_something@example.com'
      ]

      user = Factory.build :user
      valid_emails.each do |email|
        user.email = email
        user.should have(:no).errors_on(:email)
      end
    end

    it 'should not accept invalid emails' do
      invalid_emails = [
        'user',
        'example.com',
        '@example.com',
        'user.@example.com',
        'user..something@example.com',
        'user@something@else@example.com',
        'user @ example.com'
      ]

      user = Factory.build :user
      invalid_emails.each do |email|
        user.email = email
        user.should have_at_least(1).error_on(:email)
      end
    end
  end # describe 'email'

  describe '#password' do
    it 'should be required on create' do
      user = Factory.build :user, :password => nil
      user.should have_at_least(1).error_on(:password)
    end

    it 'should not be required on update' do
      # password is implemented as an attr_accessor, so when a user object
      # is loaded from the database, user.password should be nil. if something
      # else is changed, user.password should still be nil and should not cause
      # a validation error
      
      email = 'user@example.com'

      Factory.create :user, :email => email
      user = User.find_by_email email
      
      # sanity checks
      user.password.should be_nil
      user.password_digest.should_not be_nil

      user.email = 'user@example.net'
      user.should have(:no).errors_on(:password)
    end

    it 'should be downcased' do
      password = 'SOME.PASSWORD'
      user = Factory.create :user, :password => password
      BCrypt::Password.new(user.password_digest).should == password.downcase
      
      # now make sure it works when updated
      user.update_attributes :password => password
      BCrypt::Password.new(user.password_digest).should == password.downcase
    end
  end # describe '#password'

  describe 'password_digest' do
    it 'should be generated automatically' do
      email = 'user@example.com'

      Factory.create :user, :email => email
      user = User.find_by_email email
      
      user.password_digest.should_not be_nil
    end

    it 'should be changed when password is changed' do
      user = Factory.create :user
      old_password_digest = user.password_digest
      user.update_attributes :password => user.password.reverse
      user.password_digest.to_s.should_not == old_password_digest.to_s
    end

    it 'should not be changed if new password is blank' do
      user = Factory.create :user
      old_password_digest = user.password_digest
      user.update_attributes :password => nil
      user.password_digest.to_s.should == old_password_digest.to_s
    end

    it 'should not be changed if new password is empty' do
      user = Factory.create :user
      old_password_digest = user.password_digest
      user.update_attributes :password => ' '
      user.password_digest.to_s.should == old_password_digest.to_s
    end
  end # describe 'password_digest'

  describe 'uuid' do
    it 'should be generated automatically' do
      email = 'user@example.com'

      Factory.create :user, :email => email
      user = User.find_by_email email
      
      user.uuid.should_not be_nil
    end

    it 'should be changed when password is changed' do
      user = Factory.create :user
      old_uuid = user.uuid
      user.update_attributes :password => user.password.reverse
      user.uuid.should_not == old_uuid
    end

    it 'should be unique' do
      # how to test that a randomly generated value is unique? since the user is not supplying the value,
      # we cannot do something like:
      #
      #   it 'should be unique' do
      #     user_1 = Factory.create :user
      #     user_2 = Factory.build :user, :uuid => user_1.uuid
      #     user_2.should have_at_least(1).error_on(:uuid)
      #   end

      user_1 = Factory.create :user
      Factory.create :user
      # look up user so attributes will not be in memory from object creation
      user_2 = User.last
      user_2.uuid = user_1.uuid
      user_2.save
      user_2.uuid.should_not == user_1.uuid
    end
  end # describe 'uuid'

  describe 'authentication' do
    context 'with valid credentials' do
      before :each do
        email = 'user@example.com'
        password = 'user.at.example.com'
        @saved_user = Factory.create :user, :email => email, :password => password
        @authenticated_user, @message = User.authenticate(email, password)
      end
    
      it 'should return the correct user' do
        @authenticated_user.id.should == @saved_user.id
      end
    
      it "should return '#{Constants::Users::LOGIN_SUCCESSFUL}'" do
        @message.should == Constants::Users::LOGIN_SUCCESSFUL
      end
    end # context 'with valid credentials'
    
    context 'with unknown email' do
      before :each do
        email = 'right@email.com'
        password = 'right.password'
        Factory.create :user, :email => email, :password => password
        @authenticated_user, @message = User.authenticate('wrong@email.com', password)
      end
    
      it 'should return a nil user' do
        @authenticated_user.should be_nil
      end
    
      it "should return '#{Constants::Users::UNKNOWN_EMAIL}'" do
        @message.should == Constants::Users::UNKNOWN_EMAIL
      end
    end # context 'unknown email'
    
    context 'with wrong password' do
      before :each do
        email = 'right@email.com'
        password = 'right.password'
        Factory.create :user, :email => email, :password => password
        @authenticated_user, @message = User.authenticate(email, 'wrong.password')
      end

      it 'should return a nil user' do
        @authenticated_user.should be_nil
      end
    
      it "should return '#{Constants::Users::WRONG_PASSWORD}'" do
        @message.should == Constants::Users::WRONG_PASSWORD
      end
    end # context 'with wrong password'
  end # describe 'authentication'
end # describe User
