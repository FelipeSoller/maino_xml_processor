require 'rails_helper'

RSpec.describe DocumentsController, type: :controller do
  let(:user) { create(:user) }
  let(:document) { create(:document, user:) }

  before do
    sign_in user
    ActiveJob::Base.queue_adapter = :test
  end

  describe 'GET #index' do
    it 'assigns @documents' do
      document = create(:document, user:)
      get :index
      expect(assigns(:documents)).to eq([document])
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #new' do
    it 'assigns a new document to @document' do
      get :new
      expect(assigns(:document)).to be_a_new(Document)
    end

    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid files' do
      let(:valid_file) { fixture_file_upload('spec/fixtures/sample.xml', 'application/xml') }

      it 'creates a new document' do
        expect do
          post :create, params: { document: { files: [valid_file] } }, format: :turbo_stream
        end.to change(Document, :count).by(1)
      end

      it 'enqueues the ProcessXmlFileJob' do
        expect do
          post :create, params: { document: { files: [valid_file] } }, format: :turbo_stream
        end.to have_enqueued_job(ProcessXmlFileJob)
      end

      it 'redirects to the documents index with a success notice' do
        post :create, params: { document: { files: [valid_file] } }, format: :turbo_stream
        expect(response).to redirect_to(documents_path)
        expect(flash[:notice]).to eq(I18n.t('controllers.documents.alerts.all_documents_processed'))
      end
    end

    context 'with invalid file type' do
      let(:invalid_file) { fixture_file_upload('spec/fixtures/invalid_file.txt', 'text/plain') }

      it 'does not create a document and shows an error' do
        post :create, params: { document: { files: [invalid_file] } }, format: :turbo_stream
        expect(Document.count).to eq(0)
        expect(flash[:alert]).to eq(I18n.t('controllers.documents.alerts.unsupported_files', invalid_files: 'invalid_file.txt'))
      end

      it 'renders the form errors partial' do
        post :create, params: { document: { files: [invalid_file] } }, format: :turbo_stream
        expect(response).to render_template(partial: '_form_errors')
      end
    end

    context 'when no files are uploaded' do
      it 'shows an error message' do
        post :create, params: { document: { files: [""] } }, format: :turbo_stream
        expect(flash[:alert]).to eq(I18n.t('controllers.documents.alerts.no_documents_selected'))
        expect(response).to render_template(partial: '_form_errors')
      end
    end

    context 'when document fails to save' do
      let(:valid_file) { fixture_file_upload('spec/fixtures/sample.xml', 'application/xml') }

      before do
        allow_any_instance_of(Document).to receive(:save).and_return(false)
      end

      it 'renders the form errors partial with an error message' do
        post :create, params: { document: { files: [valid_file] } }, format: :turbo_stream
        expect(response).to render_template(partial: '_form_errors')
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when document exists' do
      it 'deletes the document' do
        document = create(:document, user:)
        expect do
          delete :destroy, params: { id: document.id }
        end.to change(Document, :count).by(-1)
      end

      it 'redirects to the documents index with a success notice' do
        document = create(:document, user:)
        delete :destroy, params: { id: document.id }
        expect(response).to redirect_to(documents_path)
        expect(flash[:notice]).to eq(I18n.t('controllers.documents.alerts.document_deleted'))
      end
    end

    context 'when document does not exist' do
      it 'redirects to documents index with an error message' do
        delete :destroy, params: { id: 0 }
        expect(response).to redirect_to(documents_path)
        expect(flash[:alert]).to eq(I18n.t('controllers.documents.alerts.document_not_found'))
      end
    end
  end
end
