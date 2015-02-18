require 'active_model'

module Formi
  class NestedValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless value.valid?
        value.errors.each do |name, value|
          record.errors.add name, value
        end
      end
    end
  end
end
