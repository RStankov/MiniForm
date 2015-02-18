require 'spec_helper'
require 'ostruct'

module Formi
  describe Model do
    let(:user) { OpenStruct.new name: 'Name' }

    Example = Class.new do
      include Model
      attributes :name, :price
    end

    ExampleWithDelegate = Class.new do
      include Model

      attr_reader :user

      attributes :name, delegate: :user

      def initialize(user)
        @user = user
      end
    end

    ExampleWithModel = Class.new do
      include Model

      model :user, attributes: %i(name)
    end

    describe 'acts as ActiveModel' do
      include ActiveModel::Lint::Tests

      before do
        @model = Example.new
      end

      def assert(condition, message = nil)
        expect(condition).to be_truthy, message
      end

      def assert_kind_of(expected_kind, object, message = nil)
        expect(object).to be_kind_of(expected_kind), message
      end

      def assert_equal(expected_value, value, message = nil)
        expect(value).to eq(expected_value), message
      end

      ActiveModel::Lint::Tests.public_instance_methods.map(&:to_s).grep(/^test/).each do |method|
        example(method.gsub('_', ' ')) { send method }
      end
    end

    describe '.attributes' do
      it 'generates getters' do
        object = Example.new name: 'value'
        expect(object.name).to eq 'value'
      end

      it 'generates setters' do
        object = Example.new
        object.name = 'value'

        expect(object.name).to eq 'value'
      end

      it 'can delegate getter' do
        object = ExampleWithDelegate.new user
        expect(object.name).to eq user.name
      end

      it 'can delegate setter' do
        object = ExampleWithDelegate.new user

        object.name = 'New Name'

        expect(object.name).to eq 'New Name'
        expect(user.name).to eq 'New Name'
      end
    end

    describe '.model' do
      it 'generates model accessors' do
        object = ExampleWithModel.new user: user
        expect(object.user).to eq user
      end

      it 'can delegate model attributes' do
        object = ExampleWithModel.new user: user
        expect(object.name).to eq user.name
      end
    end

    describe '.attributes_names' do
      it 'returns attribute names' do
        expect(Example.attribute_names).to eq %i(name price)
      end
    end

    describe '#initialize' do
      it 'can be called with no arguments' do
        expect { Example.new }.not_to raise_error
      end

      it 'assign the passed attributes' do
        object = Example.new price: '$5'

        expect(object.price).to eq '$5'
      end

      it 'ignores invalid attributes' do
        expect { Example.new invalid: 'attribute' }.not_to raise_error
      end

      it 'handles HashWithIndifferentAccess hashes' do
        hash   = ActiveSupport::HashWithIndifferentAccess.new 'price' => '$5'
        object = Example.new hash

        expect(object.price).to eq '$5'
      end
    end

    describe '#attributes' do
      it 'returns attributes' do
        object = Example.new name: 'iPhone', price: '$5'
        expect(object.attributes).to eq name: 'iPhone', price: '$5'
      end
    end
  end
end
