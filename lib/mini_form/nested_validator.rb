require 'active_model'

module MiniForm
  class NestedValidator < ActiveModel::EachValidator
    def validate_each(record, _, relation)
      return if relation.valid?

      relation.errors.each do |name, value|
        record.errors.add name, value
      end
    end
  end
end
