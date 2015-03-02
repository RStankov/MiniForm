require 'spec_helper'

module MiniForm
  describe NestedValidator do
    class User
      include ActiveModel::Model

      attr_accessor :name

      validates :name, presence: true
    end

    class Record
      include ActiveModel::Validations

      attr_accessor :user

      def initialize(user)
        @user = user
      end
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
