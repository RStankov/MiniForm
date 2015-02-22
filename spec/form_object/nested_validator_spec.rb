require 'spec_helper'

module FormObject
  describe NestedValidator do
    class User
      include ActiveModel::Model

      attr_accessor :name

      validates :name, presence: true
    end

    class Record < Struct.new(:user)
      include ActiveModel::Validations
    end

    let(:validator) { NestedValidator.new(attributes: [:user]) }
    let(:user)      { User.new }
    let(:record)    { Record.new(user) }

    it 'copies errors from submodel to model' do
      validator.validate(record)

      expect(record.errors[:name]).not_to be_blank
    end

    it 'does not copy errors when there are not any' do
      user.name = 'valid name'

      validator.validate(record)

      expect(record.errors[:name]).to be_blank
    end
  end
end
