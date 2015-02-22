require 'active_support/all'
require 'active_model'

module FormObject
  module Model
    def self.included(base)
      base.class_eval do
        include ActiveModel::Validations
        include ActiveModel::Conversion

        extend ActiveModel::Naming
        extend ActiveModel::Callbacks

        extend ClassMethods

        define_model_callbacks :update

        before_update :before_update
        after_update :after_update
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

    def update(attributes = {})
      self.attributes = attributes unless attributes.empty?

      return false unless valid?

      run_callbacks :update do
        transaction do
          save_models
          perform
        end
      end

      true
    end

    def update!(attributes = {})
      fail InvalidForm unless update attributes
      self
    end

    private

    def transaction(&block)
      if defined? ActiveRecord
        ActiveRecord::Base.transaction(&block)
      else
        yield
      end
    end

    def save_models
      self.class.models_to_save.each { |model_name| public_send(model_name).save! }
    end

    def perform
      # noop
    end

    def before_update
      # noop
    end

    def after_update
      # noop
    end

    module ClassMethods
      def attribute_names
        @attribute_names ||= []
      end

      def models_to_save
        @models_to_save ||= []
      end

      def attributes(*attributes, delegate: nil, prefix: nil, allow_nil: nil)
        attribute_names.push(*attributes)

        if delegate.nil?
          attr_accessor(*attributes)
        else
          self.delegate(*attributes, to: delegate, prefix: prefix, allow_nil: allow_nil)
          self.delegate(*attributes.map { |attr| "#{attr}=" }, to: delegate, prefix: prefix, allow_nil: allow_nil)
        end
      end

      def model(name, attributes: [], prefix: nil, allow_nil: nil, save: false)
        attributes(name)
        attributes(*attributes, delegate: name, prefix: prefix, allow_nil: allow_nil) unless attributes.empty?

        validates name, 'form_object/nested' => true

        models_to_save << name if save
      end
    end
  end
end
