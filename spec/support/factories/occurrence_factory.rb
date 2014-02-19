module Spendful
  module Factories
    module OccurrenceFactory
      def self.attributes(overrides = {})
        # will be nil if overrides does not have key :item_id or if item is not found
        item = overrides.delete :item
        date = item ? item.ice_cube_schedule.all_occurrences.sample : Date.ordinal(Date.today.year, SecureRandom.random_number(365) + 1)

        {
          :item => item,
          :date => date
        }.merge(overrides)
      end # def attributes

      def self.build(overrides = {})
        item = nil

        if overrides[:item]
          item = overrides.delete(:item)
        elsif overrides[:item_id]
          item = Item.find_by_id overrides[:item_id]
        end

        unless item
          # don't have an item yet ... but do we need one? if either key (:item or :item_id) is present with truthy value,
          # we would have already use it. if the following condition passes, the value must be falsey, which means the
          # caller has specifically requested an item not be constructed
          unless overrides.has_key?(:item) || overrides.has_key?(:item_id)
            attrs = { :schedule => 'monthly', :starts_on => Date.today.beginning_of_year, :ends_on => Date.today.end_of_year }
            item = ItemFactory.create attrs
          end
        end

        # # let's make sure overrides are set properly
        [:item, :item_id].each { |key| overrides.delete(key) }

        overrides[:item] = item if item

        Occurrence.new attributes(overrides)
      end
    end # class OccurrenceFactory
  end # module Factories
end # module Spendful
