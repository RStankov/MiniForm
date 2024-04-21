# frozen_string_literal: true

require 'spec_helper'

module SpecSupport
  class User
    include ActiveModel::Model

    attr_accessor :id, :name, :age

    validates :name, presence: true

    def to_param
      "user-#{id}"
    end

    def persisted?
      id.present?
    end

    def new_record?
      !persisted?
    end
  end

  class Example
    include MiniForm::Model

    attributes :name, :price
  end

  class ExampleWithDelegate
    include MiniForm::Model

    attr_reader :user

    attributes :name, delegate: :user
    attributes :id, delegate: :user, prefix: true
    attributes :name, delegate: :user, prefix: 'full'

    def initialize(user)
      @user = user
    end
  end

  class ExampleWithModel
    include MiniForm::Model

    model :user, attributes: %i(name), read: %i(id)

    def initialize(user)
      self.user = user
    end
  end

  class ExampleForUpdate
    include MiniForm::Model

    attributes :name

    validates :name, presence: true
  end

  class ExampleForSave
    include MiniForm::Model

    model :user, attributes: %i(name), save: true

    def initialize(user:)
      self.user = user
    end
  end

  class ExampleFormModel
    include MiniForm::Model

    main_model :user

    def initialize(user:)
      self.user = user
    end
  end
end

module MiniForm
  describe Model do
    let(:user) { SpecSupport::User.new id: 1, name: 'name', age: 28 }

    describe 'acts as ActiveModel' do
      include ActiveModel::Lint::Tests

      before do
        @model = SpecSupport::Example.new
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

      def assert_respond_to(klass, method, message = nil)
        expect(klass).to respond_to(method), message
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
        object = SpecSupport::Example.new name: 'value'
        expect(object.name).to eq 'value'
      end

      it 'generates setters' do
        object = SpecSupport::Example.new
        object.name = 'value'

        expect(object.name).to eq 'value'
      end

      it 'can delegate getter' do
        object = SpecSupport::ExampleWithDelegate.new user
        expect(object.name).to eq user.name
      end

      it 'can delegate setter' do
        object = SpecSupport::ExampleWithDelegate.new user

        object.name = 'New Name'

        expect(object.name).to eq 'New Name'
        expect(user.name).to eq 'New Name'
      end
    end

    describe '.model' do
      it 'generates model accessors' do
        object = SpecSupport::ExampleWithModel.new user
        expect(object.user).to eq user
      end

      it 'can delegate only a reader' do
        object = SpecSupport::ExampleWithModel.new user

        expect(object).not_to respond_to :id=
        expect(object.id).to eq user.id
      end

      it 'can delegate model attributes' do
        object = SpecSupport::ExampleWithModel.new user
        expect(object.name).to eq user.name
      end

      it 'performs nested validation for model' do
        user   = SpecSupport::User.new
        object = SpecSupport::ExampleWithModel.new user

        expect(object).not_to be_valid
        expect(object.errors[:name]).to be_present
      end
    end

    describe '.main_model' do
      it 'delegates Rails form attributes to the model' do
        user   = SpecSupport::User.new
        object = SpecSupport::ExampleFormModel.new(user: user)

        expect(object).to have_attributes(
          id: user.id,
          to_param: user.to_param,
          persisted?: user.persisted?,
          new_record?: user.new_record?
        )
      end
    end

    describe '.attributes_names' do
      it 'returns attribute names' do
        expect(SpecSupport::Example.attribute_names).to eq %i(name price)
      end

      it 'can handle prefixes' do
        expect(SpecSupport::ExampleWithDelegate.attribute_names).to include :user_id
        expect(SpecSupport::ExampleWithDelegate.attribute_names).to include :full_name
      end
    end

    describe '#initialize' do
      it 'can be called with no arguments' do
        expect { SpecSupport::Example.new }.not_to raise_error
      end

      it 'assign the passed attributes' do
        object = SpecSupport::Example.new price: '$5'

        expect(object.price).to eq '$5'
      end

      it 'ignores invalid attributes' do
        expect { SpecSupport::Example.new invalid: 'attribute' }.not_to raise_error
      end

      it 'handles HashWithIndifferentAccess hashes' do
        hash   = ActiveSupport::HashWithIndifferentAccess.new 'price' => '$5'
        object = SpecSupport::Example.new hash

        expect(object.price).to eq '$5'
      end
    end

    describe '#attributes' do
      it 'returns attributes' do
        object = SpecSupport::Example.new name: 'iPhone', price: '$5'
        expect(object.attributes).to eq name: 'iPhone', price: '$5'
      end
    end

    ['attributes=', 'assign_attributes'].each do |method_name|
      describe "##{method_name}" do
        it 'sets attributes' do
          object = SpecSupport::Example.new
          object.public_send method_name, name: 'iPhone', price: '$5'

          expect(object.attributes).to eq name: 'iPhone', price: '$5'
        end

        it 'ignores not listed attributes' do
          object = SpecSupport::Example.new
          object.public_send method_name, invalid: 'value'

          expect(object.attributes).to eq name: nil, price: nil
        end
      end
    end

    describe '#update' do
      it 'updates attributes' do
        object = SpecSupport::ExampleForUpdate.new name: 'value'

        expect { object.update(name: 'new value') }.to change { object.name }.to 'new value'
      end

      it 'returns true when validations pass' do
        object = SpecSupport::ExampleForUpdate.new name: 'value'

        expect(object.update).to eq true
      end

      it 'calls "perfom" method when validation pass' do
        object = SpecSupport::ExampleForUpdate.new name: 'value'

        allow(object).to receive(:perform)

        object.update

        expect(object).to have_received(:perform)
      end

      it 'calls "save" for the model' do
        object = SpecSupport::ExampleForSave.new user: user

        allow(user).to receive(:save!)

        object.update

        expect(user).to have_received(:save!)
      end

      it 'supports update callbacks' do
        object = SpecSupport::ExampleForUpdate.new name: 'value'

        allow(object).to receive(:before_update)
        allow(object).to receive(:after_update)

        object.update

        expect(object).to have_received(:before_update)
        expect(object).to have_received(:after_update)
      end

      it 'supports legacy assig callbacks' do
        object = SpecSupport::ExampleForUpdate.new

        allow(object).to receive(:before_assigment)
        allow(object).to receive(:after_assigment)

        object.update name: 'value'

        expect(object).to have_received(:before_assigment)
        expect(object).to have_received(:after_assigment)
      end

      it 'supports assign callbacks' do
        object = SpecSupport::ExampleForUpdate.new

        allow(object).to receive(:before_assignment)
        allow(object).to receive(:after_assignment)

        object.update name: 'value'

        expect(object).to have_received(:before_assignment)
        expect(object).to have_received(:after_assignment)
      end

      it 'returns false when validations fail' do
        object = SpecSupport::ExampleForUpdate.new name: nil

        expect(object.update).to eq false
      end

      it 'does not call "perfom" method when validation fail' do
        object = SpecSupport::ExampleForUpdate.new name: nil

        allow(object).to receive(:perform)

        object.update

        expect(object).not_to have_received(:perform)
      end
    end

    describe '#update!' do
      it 'returns self' do
        object = SpecSupport::Example.new
        expect(object.update!).to eq object
      end

      it 'calls update with given arguments' do
        object = SpecSupport::Example.new

        allow(object).to receive(:update).and_return true

        object.update! :attributes

        expect(object).to have_received(:update).with(:attributes)
      end

      it 'raises error when update fails' do
        object = SpecSupport::Example.new

        allow(object).to receive(:update).and_return false

        expect { object.update! }.to raise_error InvalidForm
      end
    end
  end
end
