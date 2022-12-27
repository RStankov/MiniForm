# frozen_string_literal: true

require 'spec_helper'

module SpecSupport
  class Person
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
end

module MiniForm
  describe NestedValidator do
    let(:validator) { described_class.new(attributes: [:user]) }
    let(:user)      { SpecSupport::Person.new }
    let(:record)    { SpecSupport::Record.new(user) }

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
