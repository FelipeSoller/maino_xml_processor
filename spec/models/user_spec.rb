require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it 'has many documents with dependent destroy' do
      user = User.reflect_on_association(:documents)
      expect(user.macro).to eq(:has_many)
      expect(user.options[:dependent]).to eq(:destroy)
    end

    it 'has many document_details with dependent destroy' do
      user = User.reflect_on_association(:document_details)
      expect(user.macro).to eq(:has_many)
      expect(user.options[:dependent]).to eq(:destroy)
    end
  end

  describe 'validations' do
    it 'validates presence of email' do
      user = User.new(email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include(I18n.t('errors.messages.blank'))
    end

    it 'validates presence of encrypted password' do
      user = User.new(password: nil)
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include(I18n.t('errors.messages.blank'))
    end

    it 'validates uniqueness of email' do
      create(:user, email: 'unique@example.com')
      user = build(:user, email: 'unique@example.com')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include(I18n.t('errors.messages.taken'))
    end

    it 'validates format of email' do
      user = build(:user, email: 'invalid_email')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include(I18n.t('errors.messages.invalid'))

      user = build(:user, email: 'valid@example.com')
      expect(user).to be_valid
    end
  end

  describe 'Devise modules' do
    it 'encrypts password' do
      user = create(:user, password: 'password123')
      expect(user.encrypted_password).not_to eq('password123')
    end
  end
end
