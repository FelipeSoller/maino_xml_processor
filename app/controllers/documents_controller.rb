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
    uploaded_files = params[:document][:files].reject(&:blank?)
    errors = []
    invalid_files = []
  
    uploaded_files.each do |uploaded_file|
      unless ['zip', 'xml'].include?(uploaded_file.original_filename.split('.').last.downcase)
        invalid_files << uploaded_file.original_filename
      end
    end
  
    if invalid_files.any?
      flash.now[:alert] = "Os seguintes arquivos não são suportados: #{invalid_files.join(', ')}. Apenas ZIP e XML são permitidos."
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("form_errors", partial: "documents/form_errors") }
      end
      return
    end
  
    if uploaded_files.empty?
      flash.now[:alert] = 'Nenhum documento válido foi selecionado.'
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("form_errors", partial: "documents/form_errors") }
      end
      return
    end
  
    uploaded_files.each do |uploaded_file|
      document = current_user.documents.build(file: uploaded_file)
  
      if document.save
        ProcessXmlFileJob.perform_later(document.id)
      else
        errors << "Erro ao enviar o documento: #{uploaded_file.original_filename}"
      end
    end
  
    if errors.empty?
      respond_to do |format|
        format.turbo_stream { redirect_to documents_path, notice: 'Todos os documentos foram enviados e processados com sucesso.' }
      end
    else
      flash.now[:alert] = errors.join(', ')
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("form_errors", partial: "documents/form_errors") }
      end
    end
  end

  def destroy
    if @document.destroy
      redirect_to documents_path, notice: 'Documento excluído com sucesso.'
    else
      redirect_to documents_path, alert: 'Erro ao excluir o documento.'
    end
  end

  private

  def set_document
    @document = current_user.documents.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = 'Documento não encontrado.'
    redirect_to documents_path
  end

  def valid_file_type
    if file.present?
      unless ['zip', 'xml'].include?(file.file.extension.downcase)
        errors.add(:file, "tipo de arquivo não é suportado. Apenas ZIP e XML são permitidos.")
      end
    end
  end

  def document_params
    params.require(:document).permit(files: [])
  end
end
