require 'rails_helper'

RSpec.describe DocumentDetailFilter, type: :service do
  let(:user) { create(:user) }
  let!(:document_detail1) { create(:document_detail, user:, dhemi: DateTime.now - 1.day, vprod: 100.0) }
  let!(:document_detail2) { create(:document_detail, user:, dhemi: DateTime.now - 5.days, vprod: 200.0) }
  let!(:emit) { create(:emit, document_detail: document_detail1, xnome: 'Empresa A') }
  let!(:dest) { create(:dest, document_detail: document_detail2, xnome: 'Cliente B') }
  let!(:det1) { create(:det, document_detail: document_detail1, xprod: 'Produto A', ncm: '1234', cfop: '5101') }
  let!(:det2) { create(:det, document_detail: document_detail2, xprod: 'Produto B', ncm: '5678', cfop: '6101') }

  describe '#apply' do
    subject { described_class.new(DocumentDetail.all, params).apply }

    context 'when filtering by date range' do
      let(:params) { { start_date: DateTime.now - 3.days, end_date: DateTime.now } }

      it 'returns document details within the date range' do
        expect(subject).to include(document_detail1)
        expect(subject).not_to include(document_detail2)
      end
    end

    context 'when filtering by emit_name' do
      let(:params) { { emit_name: 'Empresa A' } }

      it 'returns document details where emit name matches' do
        expect(subject).to include(document_detail1)
        expect(subject).not_to include(document_detail2)
      end
    end

    context 'when filtering by dest_name' do
      let(:params) { { dest_name: 'Cliente B' } }

      it 'returns document details where dest name matches' do
        expect(subject).to include(document_detail2)
        expect(subject).not_to include(document_detail1)
      end
    end

    context 'when filtering by vprod range' do
      let(:params) { { min_vprod: 150.0, max_vprod: 250.0 } }

      it 'returns document details within the product value range' do
        expect(subject).to include(document_detail2)
        expect(subject).not_to include(document_detail1)
      end
    end

    context 'when filtering by xprod' do
      let(:params) { { xprod: 'Produto A' } }

      it 'returns document details where product name matches' do
        expect(subject).to include(document_detail1)
        expect(subject).not_to include(document_detail2)
      end
    end

    context 'when filtering by ncm' do
      let(:params) { { ncm: '1234' } }

      it 'returns document details where NCM matches' do
        expect(subject).to include(document_detail1)
        expect(subject).not_to include(document_detail2)
      end
    end

    context 'when filtering by cfop' do
      let(:params) { { cfop: '5101' } }

      it 'returns document details where CFOP matches' do
        expect(subject).to include(document_detail1)
        expect(subject).not_to include(document_detail2)
      end
    end
  end
end
