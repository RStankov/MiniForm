require 'spec_helper'

module MiniForm
  describe Model do
    let(:user) { User.new name: 'Name' }

    class User
      include ActiveModel::Model

      attr_accessor :name

      validates :name, presence: true
    end

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

      it 'performs nested validation for model' do
        user   = User.new
        object = ExampleWithModel.new user: user

        expect(object).not_to be_valid
        expect(object.errors[:name]).to be_present
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

    describe '#update' do
      ExampleForUpdate = Class.new do
        include Model

        attributes :name

        validates :name, presence: true
      end

      ExampleForSave = Class.new do
        include Model

        model :user, attributes: %i(name), save: true
      end

      it 'updates attributes' do
        object = ExampleForUpdate.new name: 'value'

        expect { object.update(name: 'new value') }.to change { object.name }.to 'new value'
      end

      it 'returns true when validations pass' do
        object = ExampleForUpdate.new name: 'value'

        expect(object.update).to eq true
      end

      it 'calls "perfom" method when validation pass' do
        object = ExampleForUpdate.new name: 'value'

        expect(object).to receive(:perform)

        object.update
      end

      it 'calls "save" for the model' do
        object = ExampleForSave.new user: user

        allow(user).to receive(:save!)

        object.update

        expect(user).to have_received(:save!)
      end

      it 'supports update callbacks' do
        object = ExampleForUpdate.new name: 'value'

        expect(object).to receive(:before_update)
        expect(object).to receive(:after_update)

        object.update
      end

      it 'returns false when validations fail' do
        object = ExampleForUpdate.new name: nil

        expect(object.update).to eq false
      end

      it 'does not call "perfom" method when validation fail' do
        object = ExampleForUpdate.new name: nil

        expect(object).not_to receive(:perform)

        object.update
      end
    end

    describe '#update!' do
      it 'returns self' do
        object = Example.new
        expect(object.update!).to eq object
      end

      it 'calls update with given arguments' do
        object = Example.new

        expect(object).to receive(:update).with(:attributes).and_return true

        object.update! :attributes
      end

      it 'raises error when update fails' do
        object = Example.new

        allow(object).to receive(:update).and_return false

        expect { object.update! }.to raise_error InvalidForm
      end
    end
  end
end
