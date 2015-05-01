module MiniForm
  class InvalidForm < StandardError
    attr_reader :errors

    def initialize(object)
      @errors = object.errors

      super "Form validation failed for: #{errors.keys.join(', ')}"
    end
  end
end
