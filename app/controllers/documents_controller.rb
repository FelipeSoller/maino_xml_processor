class DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_document, only: [:destroy]

  def index
    @documents = current_user.documents
  end

  def new
    @document = Document.new
  end

  def create
    uploaded_files = document_params[:files].reject(&:blank?)
    invalid_files = []

    uploaded_files.each do |uploaded_file|
      unless ['zip', 'xml'].include?(uploaded_file.content_type.split('/').last.downcase)
        invalid_files << uploaded_file.original_filename
      end
    end

    if invalid_files.any?
      flash.now[:alert] = t('controllers.documents.alerts.unsupported_files', invalid_files: invalid_files.join(', '))
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("form_errors", partial: "documents/form_errors") }
      end
      return
    end

    if uploaded_files.empty?
      flash.now[:alert] = t('controllers.documents.alerts.no_documents_selected')
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("form_errors", partial: "documents/form_errors") }
      end
      return
    end

    @document = current_user.documents.build

    if @document.save
      @document.files.attach(uploaded_files)
      @document.files.each do |file|
        ProcessXmlFileJob.perform_later(file.signed_id, @document.id)
      end
      redirect_to documents_path, notice: t('controllers.documents.alerts.all_documents_processed')
    else
      Rails.logger.error("Erro ao salvar documento: #{@document.errors.full_messages.join(', ')}")
      flash.now[:alert] = @document.errors.full_messages.join(', ')
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("form_errors", partial: "documents/form_errors") }
      end
    end
  end

  def destroy
    if @document.destroy
      redirect_to documents_path, notice: t('controllers.documents.alerts.document_deleted')
    else
      redirect_to documents_path, alert: t('controllers.documents.alerts.document_delete_error')
    end
  end

  private

  def set_document
    @document = current_user.documents.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = t('controllers.documents.alerts.document_not_found')
    redirect_to documents_path
  end

  def document_params
    params.require(:document).permit(files: [])
  end
end
