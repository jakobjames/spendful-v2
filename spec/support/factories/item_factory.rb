module Spendful
  module Factories
    module ItemFactory
      def self.attributes(overrides = {})
        # in tests, only build/create a 'once' item when asked to...this is because many of the tests
        # need to access occurrences, which will ultimately need an ends_on so IceCube can return
        # all of the occurrence dates.
        schedules = Constants::Items::SCHEDULES.dup - ['once']

        category = overrides.has_key?(:category) ? overrides[:category] : Constants::Items::CATEGORIES.sample
        name = overrides.has_key?(:name) ? overrides[:name] : Faker::Name.name
        amount = overrides.has_key?(:amount) ? overrides[:amount] : SecureRandom.random_number(1000)
        schedule = overrides.has_key?(:schedule) ? overrides[:schedule] : schedules.sample
        starts_on = overrides.has_key?(:starts_on) ? overrides[:starts_on] : Date.ordinal(Date.today.year, SecureRandom.random_number(365) + 1)
        
        if overrides.has_key?(:ends_on)
          ends_on = overrides[:ends_on]
        else
          if starts_on
            ends_on =
              case schedule
                when 'once'
                  nil
                when 'weekly'
                  starts_on + (SecureRandom.random_number(52) + 1).weeks
                when 'fortnightly'
                  starts_on + ((SecureRandom.random_number(26) + 1) * 2).weeks
                when 'monthly'
                  starts_on + (SecureRandom.random_number(12) + 1).months
                when 'yearly'
                  starts_on + (SecureRandom.random_number(5) + 1).years
              end
          else
            ends_on = nil
          end
        end

        # going to use reverse_merge here because I just set the values based on overrides. However, there might
        # be other keys in overrides that need to be used (like budget_id), so I still need to merge. Using
        # reverse_merge will give precedence to the values already in the receiver, which is what we want in this
        # case.
        {
          :category => category,
          :name => name,
          :amount => amount,
          :schedule => schedule,
          :starts_on => starts_on,
          :ends_on => ends_on
        }.reverse_merge(overrides)
      end # def attributes

      def self.build(overrides = {})
        # :budget takes precedence over :budget_id
        if overrides.has_key?(:budget)
          overrides[:budget_id] = overrides[:budget].id if overrides[:budget]
          overrides.delete :budget
        elsif overrides.has_key?(:budget_id)
          overrides.delete(:budget_id) unless overrides[:budget_id]
        end

        unless overrides[:budget_id]
          # if it isn't set at this point, we need to create a budget
          overrides[:budget_id] = BudgetFactory.create.id
        end

        Item.new attributes(overrides)
      end

      def self.create(overrides = {})
        model = build overrides
        model.save
        model
      end
    end # class ItemFactory
  end # module Factories
end # module Spendful