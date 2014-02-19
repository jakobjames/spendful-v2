module Spendful
  module Factories
    module BudgetFactory
      def self.attributes(overrides = {})
        currency = CountryFactory::CURRENCIES[CountryFactory::COUNTRY_CODES.sample]

        {
          :name => Faker::Name.name,
          :initial_balance => SecureRandom.random_number(5000),
          :currency => currency
        }.merge(overrides)
      end # def attributes

      def self.build(overrides = {})
        # :user takes precedence over :user_id
        if overrides.has_key?(:user)
          overrides[:user_id] = overrides[:user].id if overrides[:user]
          overrides.delete :user
        elsif overrides.has_key?(:user_id)
          overrides.delete(:user_id) unless overrides[:user_id]
        end

        unless overrides[:user_id]
          # if it isn't set at this point, we need to create a user
          overrides[:user_id] = UserFactory.create.id
        end

        Budget.new attributes(overrides)
      end

      def self.create(overrides = {})
        model = build overrides
        model.save
        model
      end
    end # class UserFactory
  end # module Factories
end # module Spendful