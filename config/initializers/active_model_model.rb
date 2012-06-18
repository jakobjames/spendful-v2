# Model module was added to master branch after 3.2.6 release and I'm doing
# this to be consistent with future versions. When we upgrade to a newer version
# of Rails that has this module, we can just remove this file and everything
# should continue to work.
unless ActiveModel.const_defined?('Model')
  module ActiveModel::Model
    def self.included(base)
      base.class_eval do
        extend  ActiveModel::Naming
        extend  ActiveModel::Translation
        include ActiveModel::Validations
        include ActiveModel::Conversion
      end
    end

    def initialize(params={})
      params.each do |attr, value|
        self.public_send("#{attr}=", value)
      end if params
    end

    def persisted?
      false
    end
  end # module ActiveModel::Model
end # unless ActiveModel.const_defined?('Model')