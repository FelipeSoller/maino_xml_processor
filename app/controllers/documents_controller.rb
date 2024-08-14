class DocumentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @documents = current_user.documents
  end

  def new
    @document = Document.new
  end

  def create
    @document = current_user.documents.build(document_params)

    if @document.save
      ProcessXmlFileJob.perform_later(@document.id) # Enfileirar o job para processamento em background
      redirect_to documents_path, notice: 'Documento enviado com sucesso. Processamento iniciado.'
    else
      render :new
    end
  end

  private

  def document_params
    params.require(:document).permit(:file)
  end
end
