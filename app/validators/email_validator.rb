require 'mail'

class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil? && options[:allow_nil]
    return if value.blank? && options[:allow_blank]

    message = options[:message] || 'is not valid'
    record.errors[attribute] << message and return if value.nil? || value.blank?
    # shouldn't allow multiple dots (..), but the parser doesn't catch it
    record.errors[attribute] << message and return if value =~ /\.{2,}/

    # don't allow any spaces
    record.errors[attribute] << message and return if value =~ /\s+/

    parser = Mail::RFC2822Parser.new
    parser.root = :addr_spec
    result = parser.parse(value)

    # Don't allow for a TLD by itself list (sam@localhost)
    # The Grammar is: (local_part"@"domain) / local_part ... discard latter
    valid = !!result
    valid = result.respond_to?(:domain) if valid
    valid = result.domain.dot_atom_text.elements.size > 1 if valid

    record.errors[attribute] << message unless valid
  end
end
