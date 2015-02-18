require 'active_support/all'
require 'active_model'

module Formi
  module Model
    def self.included(base)
      base.class_eval do
        include ActiveModel::Validations
        include ActiveModel::Conversion

        extend ActiveModel::Naming
        extend ClassMethods

        @attribute_names = []
      end
    end

    def initialize(attributes = {})
      self.attributes = attributes
    end

    def persisted?
      false
    end

    def attributes=(attributes)
      attributes.slice(*self.class.attribute_names).each do |name, value|
        public_send "#{name}=", value
      end
    end

    def attributes
      Hash[self.class.attribute_names.map { |name| [name, public_send(name)] }]
    end

    module ClassMethods
      attr_reader :attribute_names

      def attributes(*attributes, delegate: nil, prefix: nil, allow_nil: nil)
        @attribute_names.push(*attributes)

        if delegate.nil?
          attr_accessor(*attributes)
        else
          self.delegate(*attributes, to: delegate, prefix: prefix, allow_nil: allow_nil)
          self.delegate(*attributes.map { |attr| "#{attr}=" }, to: delegate, prefix: prefix, allow_nil: allow_nil)
        end
      end

      def model(name, attributes: [], prefix: nil, allow_nil: nil)
        attributes(name)
        attributes(*attributes, delegate: name, prefix: prefix, allow_nil: allow_nil) unless attributes.empty?
      end
    end
  end
end
