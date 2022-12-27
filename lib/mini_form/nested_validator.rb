# frozen_string_literal: true

require 'active_model'

module MiniForm
  class NestedValidator < ActiveModel::EachValidator
    def validate_each(record, _, relation)
      return if relation.valid?

      if record.errors.respond_to?(:merge!)
        # Rails 6.1+ where accessing ActiveModel::Errors as a hash has been
        # deprecated and the errors array is frozen. For this reason we use the new
        # method merge!() which appends the errors as NestedErrors to the array. "This is the way."
        record.errors.merge!(relation.errors)
        return
      end

      # Rails < 6.1
      relation.errors.each do |name, value|
        record.errors.add name, value
      end
    end
  end
end
