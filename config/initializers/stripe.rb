Stripe.api_key = ENV['STRIPE_API_KEY']
STRIPE_PUBLIC_KEY = ENV['STRIPE_PUBLIC_KEY']

StripeEvent.setup do
  subscribe 'charge.succeeded' do |event|
    customer = event.data.object.customer
    subscription = Subscription.find_by_reference(customer)
    if subscription.present?
      plan = Constants::Subscriptions::PLANS.reject{ |p| p if p[:id] != subscription.plan }[0]
      subscription.update_attributes({:expires_on => Date.today + plan[:interval]})
    end
  end
end
