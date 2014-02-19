module Spendful
  module Factories
    module Factory
      def self.build(factory, overrides = {})
        klass = "Spendful::Factories::#{factory.to_s.humanize}Factory".constantize
        klass.build overrides
      end

      def self.create(factory, overrides = {})
        klass = "Spendful::Factories::#{factory.to_s.humanize}Factory".constantize
        klass.create overrides
      end
    end
  end
end
