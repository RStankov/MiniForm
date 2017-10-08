require 'spec_helper'

module MiniForm
  describe Model do
    let(:user) { User.new id: 1, name: 'name', age: 28 }

    class User
      include ActiveModel::Model

      attr_accessor :id, :name, :age

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
      attributes :id, delegate: :user, prefix: true
      attributes :name, delegate: :user, prefix: 'full'

      def initialize(user)
        @user = user
      end
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

    describe 'inheritance' do
      it 'can be inherited' do
        parent_class = Class.new do
          include Model

          attributes :name
        end

        child_class = Class.new(parent_class) do
          attributes :age
        end

        expect(parent_class.attribute_names).to eq %i(name)
        expect(child_class.attribute_names).to eq %i(name age)
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
      ExampleWithModel = Class.new do
        include Model

        model :user, attributes: %i(name), read: %i(id)

        def initialize(user)
          self.user = user
        end
      end

      it 'generates model accessors' do
        object = ExampleWithModel.new user
        expect(object.user).to eq user
      end

      it 'can delegate only a reader' do
        object = ExampleWithModel.new user

        expect(object).not_to respond_to :id=
        expect(object.id).to eq user.id
      end

      it 'can delegate model attributes' do
        object = ExampleWithModel.new user
        expect(object.name).to eq user.name
      end

      it 'performs nested validation for model' do
        user   = User.new
        object = ExampleWithModel.new user

        expect(object).not_to be_valid
        expect(object.errors[:name]).to be_present
      end
    end

    describe '.attributes_names' do
      it 'returns attribute names' do
        expect(Example.attribute_names).to eq %i(name price)
      end

      it 'can handle prefixes' do
        expect(ExampleWithDelegate.attribute_names).to include :user_id
        expect(ExampleWithDelegate.attribute_names).to include :full_name
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

    ['attributes=', 'assign_attributes'].each do |method_name|
      describe "##{method_name}" do
        it 'sets attributes' do
          object = Example.new
          object.public_send method_name, name: 'iPhone', price: '$5'

          expect(object.attributes).to eq name: 'iPhone', price: '$5'
        end

        it 'ignores not listed attributes' do
          object = Example.new
          object.public_send method_name, invalid: 'value'

          expect(object.attributes).to eq name: nil, price: nil
        end
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

        def initialize(user:)
          self.user = user
        end
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

        allow(object).to receive(:perform)

        object.update

        expect(object).to have_received(:perform)
      end

      it 'calls "save" for the model' do
        object = ExampleForSave.new user: user

        allow(user).to receive(:save!)

        object.update

        expect(user).to have_received(:save!)
      end

      it 'supports update callbacks' do
        object = ExampleForUpdate.new name: 'value'

        allow(object).to receive(:before_update)
        allow(object).to receive(:after_update)

        object.update

        expect(object).to have_received(:before_update)
        expect(object).to have_received(:after_update)
      end

      it 'supports legacy assig callbacks' do
        object = ExampleForUpdate.new

        allow(object).to receive(:before_assigment)
        allow(object).to receive(:after_assigment)

        object.update name: 'value'

        expect(object).to have_received(:before_assigment)
        expect(object).to have_received(:after_assigment)
      end

      it 'supports assign callbacks' do
        object = ExampleForUpdate.new

        allow(object).to receive(:before_assignment)
        allow(object).to receive(:after_assignment)

        object.update name: 'value'

        expect(object).to have_received(:before_assignment)
        expect(object).to have_received(:after_assignment)
      end

      it 'returns false when validations fail' do
        object = ExampleForUpdate.new name: nil

        expect(object.update).to eq false
      end

      it 'does not call "perfom" method when validation fail' do
        object = ExampleForUpdate.new name: nil

        allow(object).to receive(:perform)

        object.update

        expect(object).not_to have_received(:perform)
      end
    end

    describe '#update!' do
      it 'returns self' do
        object = Example.new
        expect(object.update!).to eq object
      end

      it 'calls update with given arguments' do
        object = Example.new

        allow(object).to receive(:update).and_return true

        object.update! :attributes

        expect(object).to have_received(:update).with(:attributes)
      end

      it 'raises error when update fails' do
        object = Example.new

        allow(object).to receive(:update).and_return false

        expect { object.update! }.to raise_error InvalidForm
      end
    end
  end
end
