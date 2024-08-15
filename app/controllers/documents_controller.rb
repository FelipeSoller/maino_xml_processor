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

    if uploaded_files.present?
      uploaded_files.each do |uploaded_file|
        document = current_user.documents.build(file: uploaded_file)

        if document.save
          ProcessXmlFileJob.perform_later(document.id) 
        else
          errors << "Erro ao enviar o documento: #{uploaded_file.original_filename}"
        end
      end

      if errors.empty?
        redirect_to documents_path, notice: 'Todos os documentos foram processados com sucesso.'
      else
        flash[:alert] = errors.join(', ')
        render :new
      end
    else
      flash[:alert] = 'Nenhum documento válido foi selecionado.'
      render :new
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

  def document_params
    params.require(:document).permit(files: [])
  end
end
