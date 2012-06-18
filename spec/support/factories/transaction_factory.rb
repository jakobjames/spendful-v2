module Spendful
  module Factories
    module TransactionFactory
      def self.attributes(overrides = {})
        # will be nil if overrides does not have key :item_id or if item is not found
        item = Item.find_by_id(overrides[:item_id])

        category = item ? item.category : Constants::Items::CATEGORIES.sample
        occurrence = (item && item.ends_on) ? item.occurrences.all.sample.date : nil
        date = occurrence ? occurrence + 1.day : Date.ordinal(Date.today.year, SecureRandom.random_number(365) + 1)

        {
          :category => category,
          :description => [Faker::Name.name, nil].sample,
          :amount => SecureRandom.random_number(1000),
          :occurrence => occurrence,
          :date => date
        }.merge(overrides)
      end # def attributes

      def self.build(overrides = {})
        budget = nil
        item = nil

        if overrides[:item]
          item = overrides.delete(:item)
        elsif overrides[:item_id]
          item = Item.find_by_id overrides[:item_id]
        end

        if item
          budget = item.budget
        elsif overrides[:budget]
          budget = overrides.delete(:budget)
        elsif overrides[:budget_id]
          budget = Budget.find_by_id overrides[:budget_id]
        end

        # if no budget by this point, create one
        budget ||= BudgetFactory.create

        unless item
          # don't have an item yet ... but do we need one? if either key (:item or :item_id) is present with truthy value,
          # we would have already use it. if the following condition passes, the value must be falsey, which means the
          # caller has specifically requested an item not be constructed
          unless overrides.has_key?(:item) || overrides.has_key?(:item_id)
            attrs = { :budget_id => budget.id, :schedule => 'monthly', :starts_on => Date.today.beginning_of_year, :ends_on => Date.today.end_of_year }
            item = ItemFactory.create attrs
          end
        end

        # let's make sure overrides are set properly
        [:budget, :budget_id, :item, :item_id].each { |key| overrides.delete(key) }

        overrides[:budget_id] = budget.id
        overrides[:item_id] = item.id if item

        Transaction.new attributes(overrides)
      end

      def self.create(overrides = {})
        model = build overrides
        model.save
        model
      end
    end # class TransactionFactory
  end # module Factories
end # module Spendful
