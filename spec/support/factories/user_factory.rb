module Spendful
  module Factories
    module UserFactory
      def self.attributes(overrides = {})
        {
          :email => Faker::Internet.email,
          :password => Faker::Base.bothify('?#?#?#?#?#?#?#?')
        }.merge(overrides)
      end # def attributes

      def self.build(overrides = {})
        country = nil

        if overrides[:country]
          country = overrides.delete(:country)
        elsif overrides[:country_id]
          country = Country.find_by_id overrides[:country_id]
        end

        unless country
          # don't have a country yet ... but do we need one? if either key (:country or :country_id) is present with truthy value,
          # we would have already use it. if the following condition passes, the value must be falsey, which means the
          # caller has specifically requested a country not be constructed
          unless overrides.has_key?(:country) || overrides.has_key?(:country_id)
            country = CountryFactory.create
          end
        end
        
        # let's make sure overrides are set properly
        [:country, :country_id].each { |key| overrides.delete(key) }
        overrides[:country_id] = country.id if country

        User.new attributes(overrides)
      end

      def self.create(overrides = {})
        model = build overrides
        model.save
        model
      end
    end # class UserFactory
  end # module Factories
end # module Spendful