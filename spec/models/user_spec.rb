require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'validates presence of email' do
      user = User.new
      user.valid?
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'validates presence of phone_number' do
      user = User.new
      user.valid?
      expect(user.errors[:phone_number]).to include("can't be blank")
    end

    it 'validates uniqueness of phone_number' do
      existing_user = create(:user, phone_number: '+639123456789')
      user = build(:user, phone_number: '+639123456789')
      user.valid?
      expect(user.errors[:phone_number]).to include('has already been taken')
    end

    it 'allows valid phone_number format' do
      user = User.new(phone_number: '+639123456789')
      user.valid?
      expect(user.errors[:phone_number]).to be_empty
    end

    it 'does not allow invalid phone_number format' do
      user = User.new(phone_number: '1234567890')
      user.valid?
      expect(user.errors[:phone_number]).to include('is in invalid number.')
    end
  end

  describe 'associations' do
    it 'has many user_roles with dependent destroy' do
      user = User.reflect_on_association(:user_roles)
      expect(user.macro).to eq(:has_many)
      expect(user.options[:dependent]).to eq(:destroy)
    end

    it 'has many roles through user_roles' do
      user = User.reflect_on_association(:roles)
      expect(user.macro).to eq(:has_many)
      expect(user.options[:through]).to eq(:user_roles)
    end

    it 'has many cryptos through user_cryptos' do
      user = User.reflect_on_association(:cryptos)
      expect(user.macro).to eq(:has_many)
      expect(user.options[:through]).to eq(:user_cryptos)
    end

    it 'has many transactions' do
      user = User.reflect_on_association(:transactions)
      expect(user.macro).to eq(:has_many)
    end
  end

end
