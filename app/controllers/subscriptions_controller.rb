class SubscriptionsController < ApplicationController

  skip_before_filter :check_subscription, :only => [:index, :new, :payment, :create]

  def index
    redirect_to(new_subscription_path) unless self.current_user.subscriptions.any?
  end

  def new
    redirect_to(subscriptions_path) if self.current_user.premium?
    @plans = []
    Constants::Subscriptions::PLANS.each do |plan|
      @plans.push ["#{plan[:name]} &mdash; &pound;#{plan[:amount]}".html_safe, plan[:id]]
    end
  end
  
  def payment
    redirect_to(subscriptions_path) if self.current_user.premium?
    @plan = params[:plan]
  end

  def create
    redirect_to(subscriptions_path) if self.current_user.premium?
    
    token = params[:stripeToken]
    plan = Constants::Subscriptions::PLANS.reject{ |p| p if p[:id] != params[:plan] }[0]
    
    
    customer = Stripe::Customer.create(
      :card => token,
      :plan => plan[:id],
      :email => current_user.email
    )
    
    @subscription = current_user.subscriptions.new({
      :plan => plan[:id],
      :reference => customer.id,
      :started_on => Date.today,
      :expires_on => Date.today + 1.day,
      :card_type => customer.active_card.type,
      :card_last4 => customer.active_card.last4,
      :card_name => customer.active_card.name
    })
    
    @user = self.current_user
    @user.update_personal({
      :name => params[:name],
      :address_line1 => params[:address_line1],
      :address_line2 => params[:address_line2],
      :address_city => params[:address_city],
      :address_zip => params[:address_zip],
      :country => params[:country]
    })
    self.current_user = @user
    
    if @subscription.save
      flash[:notice] = "You now have Spendful Premium!"
      redirect_to subscriptions_path
    else
      flash[:error] = "There was a problem starting your subscription"
      render :payment
    end
  end
  
  def destroy
    @subscription = current_user.subscriptions.find(params[:id])
    # customer = Stripe::Customer.retrieve(@subscription.reference)
    # customer.delete
    @subscription.update_attributes({:cancelled_on => Date.today})
    flash[:notice] = "Your Premium subscription has been cancelled"
    redirect_to subscriptions_path
  end

end
