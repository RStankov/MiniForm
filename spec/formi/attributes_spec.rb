require 'spec_helper'
require 'ostruct'

module Formi
  describe Attributes do
    ExampleObject = Class.new do
      include Attributes
      attributes :name, :price
    end

    ExampleObjectWithDelegate = Class.new do
      include Attributes

      attr_reader :user

      attributes :name, delegate: :user

      def initialize(user)
        @user = user
      end
    end

    let(:user) { OpenStruct.new name: 'Name' }

    describe '.attributes' do
      it 'generates getters' do
        object = ExampleObject.new name: 'value'
        expect(object.name).to eq 'value'
      end

      it 'generates setters' do
        object = ExampleObject.new
        object.name = 'value'

        expect(object.name).to eq 'value'
      end

      it 'can delegate getter' do
        object = ExampleObjectWithDelegate.new user
        expect(object.name).to eq user.name
      end

      it 'can delegate setter' do
        object = ExampleObjectWithDelegate.new user

        object.name = 'New Name'

        expect(object.name).to eq 'New Name'
        expect(user.name).to eq 'New Name'
      end
    end

    describe '.attributes_names' do
      it 'returns attribute names' do
        expect(ExampleObject.attribute_names).to eq %i(name price)
      end
    end

    describe '#initialize' do
      it 'can be called with no arguments' do
        expect { ExampleObject.new }.not_to raise_error
      end

      it 'assign the passed attributes' do
        object = ExampleObject.new price: '$5'

        expect(object.price).to eq '$5'
      end

      it 'ignores invalid attributes' do
        expect { ExampleObject.new invalid: 'attribute' }.not_to raise_error
      end

      it 'handles HashWithIndifferentAccess hashes' do
        hash   = ActiveSupport::HashWithIndifferentAccess.new 'price' => '$5'
        object = ExampleObject.new hash

        expect(object.price).to eq '$5'
      end
    end

    describe '#attributes' do
      it 'returns attributes' do
        object = ExampleObject.new name: 'iPhone', price: '$5'
        expect(object.attributes).to eq name: 'iPhone', price: '$5'
      end
    end
  end
end
