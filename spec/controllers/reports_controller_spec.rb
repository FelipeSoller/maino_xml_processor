require 'rails_helper'

RSpec.describe ReportsController, type: :controller do
  let(:user) { create(:user) }
  let(:document_detail) { create(:document_detail, user:) }

  before do
    sign_in user
    ActiveJob::Base.queue_adapter = :test
  end

  describe 'GET #index' do
    it 'assigns @document_details' do
      document_detail = create(:document_detail, user:)
      get :index
      expect(assigns(:document_details)).to eq([document_detail])
    end

    it 'filters document_details based on parameters' do
      document_detail1 = create(:document_detail, user:, created_at: 1.day.ago)
      create(:document_detail, user:, created_at: 2.days.ago)

      get :index, params: { start_date: 1.day.ago.to_date }
      expect(assigns(:document_details)).to include(document_detail1)
    end

    before do
      allow(DocumentDetail).to receive(:page).and_return(DocumentDetail.page(1).per(10))
    end

    it 'paginates the document_details' do
      create_list(:document_detail, 15, user:)
      get :index
      expect(assigns(:document_details).size).to eq(10) # Valor esperado por página
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    context 'when document_detail exists' do
      it 'assigns @document_detail' do
        get :show, params: { id: document_detail.id }
        expect(assigns(:document_detail)).to eq(document_detail)
      end

      it 'renders the show template' do
        get :show, params: { id: document_detail.id }
        expect(response).to render_template(:show)
      end
    end

    context 'when document_detail does not exist' do
      it 'redirects to the reports index with an error message' do
        get :show, params: { id: 0 }
        expect(response).to redirect_to(reports_path)
        expect(flash[:alert]).to eq(I18n.t('controllers.reports.alerts.document_not_found'))
      end
    end
  end

  describe 'POST #export_documents' do
    context 'when no documents are selected' do
      it 'redirects to the reports index with an error message' do
        post :export_documents, params: { document_detail_ids: [] }
        expect(response).to redirect_to(reports_path)
        expect(flash[:alert]).to eq(I18n.t('controllers.reports.alerts.no_documents_selected'))
      end
    end

    context 'when a single document is selected' do
      it 'generates an XLS file and sends it as a response' do
        document_detail = create(:document_detail, user:)
        report_service = instance_double(ReportExportService)
        allow(ReportExportService).to receive(:new).and_return(report_service)
        allow(report_service).to receive(:generate_xls).and_return('xls_data')

        expect(controller).to receive(:send_data).with('xls_data',
                                                       hash_including(filename: /documento_detalhado_\d{14}.xlsx/, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                                                                      disposition: 'attachment'))

        post :export_documents, params: { document_detail_ids: [document_detail.id] }
      end
    end

    context 'when multiple documents are selected' do
      it 'generates a ZIP file containing multiple XLS files and sends it as a response' do
        document_detail1 = create(:document_detail, user:)
        document_detail2 = create(:document_detail, user:)

        report_service = instance_double(ReportExportService)
        allow(ReportExportService).to receive(:new).and_return(report_service)
        allow(report_service).to receive(:generate_zip).and_return('zip_data')

        expect(controller).to receive(:send_data).with('zip_data', hash_including(filename: /relatorios_exportados_\d{14}.zip/, type: 'application/zip', disposition: 'attachment'))

        post :export_documents, params: { document_detail_ids: [document_detail1.id, document_detail2.id] }
      end
    end
  end
end
