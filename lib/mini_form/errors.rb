# frozen_string_literal: true

module MiniForm
  class InvalidForm < StandardError
    attr_reader :errors

    def initialize(object)
      @errors = object.errors

      arr_obj = errors.respond_to?(:attribute_names) ? errors.attribute_names : errors.keys
      super "Form validation failed for: #{arr_obj.join(', ')}"
    end
  end
end
