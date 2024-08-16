require 'rails_helper'

RSpec.describe DocumentDetail, type: :model do
  let(:user) { create(:user) }
  let(:document) { create(:document, user:) }

  describe 'associations' do
    it 'belongs to user' do
      association = DocumentDetail.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end

    it 'belongs to document' do
      association = DocumentDetail.reflect_on_association(:document)
      expect(association.macro).to eq(:belongs_to)
    end

    it 'has many dets with dependent destroy' do
      association = DocumentDetail.reflect_on_association(:dets)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it 'has one emit with dependent destroy' do
      association = DocumentDetail.reflect_on_association(:emit)
      expect(association.macro).to eq(:has_one)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it 'has one dest with dependent destroy' do
      association = DocumentDetail.reflect_on_association(:dest)
      expect(association.macro).to eq(:has_one)
      expect(association.options[:dependent]).to eq(:destroy)
    end
  end

  describe 'validations' do
    it 'validates presence of user' do
      document_detail = DocumentDetail.new(user: nil, document:)
      expect(document_detail).not_to be_valid
      expect(document_detail.errors[:user]).to include(I18n.t('errors.messages.blank'))
    end

    it 'validates presence of document' do
      document_detail = DocumentDetail.new(user:, document: nil)
      expect(document_detail).not_to be_valid
      expect(document_detail.errors[:document]).to include(I18n.t('errors.messages.required'))
    end
  end

  describe 'scopes' do
    let!(:document_detail1) { create(:document_detail, user:, document:, dhemi: 2.days.ago) }
    let!(:document_detail2) { create(:document_detail, user:, document:, dhemi: 1.day.ago) }

    it 'filters by date range' do
      result = DocumentDetail.by_date_range(3.days.ago, 1.day.ago)
      expect(result).to include(document_detail1, document_detail2)
    end

    it 'filters by emit name' do
      create(:emit, document_detail: document_detail1, xnome: "Company A")
      result = DocumentDetail.by_emit_name("Company A")
      expect(result).to include(document_detail1)
      expect(result).not_to include(document_detail2)
    end

    it 'filters by dest name' do
      create(:dest, document_detail: document_detail2, xnome: "Company B")
      result = DocumentDetail.by_dest_name("Company B")
      expect(result).to include(document_detail2)
      expect(result).not_to include(document_detail1)
    end

    it 'filters by vprod range' do
      document_detail1.update(vprod: 100)
      document_detail2.update(vprod: 200)

      result = DocumentDetail.by_vprod_range(50, 150)
      expect(result).to include(document_detail1)
      expect(result).not_to include(document_detail2)
    end

    it 'filters by xprod' do
      create(:det, document_detail: document_detail1, xprod: "Product A")
      result = DocumentDetail.by_xprod("Product A")
      expect(result).to include(document_detail1)
      expect(result).not_to include(document_detail2)
    end

    it 'filters by ncm' do
      create(:det, document_detail: document_detail1, ncm: "1234")
      result = DocumentDetail.by_ncm("1234")
      expect(result).to include(document_detail1)
      expect(result).not_to include(document_detail2)
    end

    it 'filters by cfop' do
      create(:det, document_detail: document_detail1, cfop: "5678")
      result = DocumentDetail.by_cfop("5678")
      expect(result).to include(document_detail1)
      expect(result).not_to include(document_detail2)
    end
  end
end
