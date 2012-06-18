module Spendful
  module Factories
    module CountryFactory
      COUNTRY_CODES = %w(US GB FR ES CA)
      COUNTRY_NAMES = {
        'US' => 'United States',
        'GB' => 'United Kingdom',
        'FR' => 'France',
        'ES' => 'Spain',
        'CA' => 'Canada'
      }
      CURRENCIES = {
        'US' => 'USD',
        'GB' => 'GBP',
        'FR' => 'EUR',
        'ES' => 'EUR',
        'CA' => 'CAD'
      }

      def self.attributes(overrides = {})
        code = COUNTRY_CODES.sample
        name = COUNTRY_NAMES[code]
        currency = CURRENCIES[code]

        {
          :code => code,
          :name => name,
          :currency => currency
        }.merge(overrides)
      end # def attributes

      def self.build(overrides = {})
        Country.new attributes(overrides)
      end

      def self.create(overrides = {})
        model = build overrides
        model.save
        model
      end
    end # class CountryFactory
  end # module Factories
end # module Spendful