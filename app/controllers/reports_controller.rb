class ReportsController < ApplicationController
  include ActionView::Helpers::NumberHelper
  before_action :authenticate_user!
  before_action :set_document_detail, only: [:show, :download]

  def index
    @document_details = current_user.document_details.includes(:emit, :dest, :dets)
    
    @document_details = apply_filters(@document_details)
    
    @document_details = @document_details.order(created_at: :desc).page(params[:page])
  end

  def show
    @document_detail = current_user.document_details.find(params[:id])
  end

  def export_documents
    document_details = selected_document_details

    if document_details.empty?
      redirect_to reports_path, alert: "Nenhum documento encontrado para exportação."
      return
    end

    report_service = ReportExportService.new(document_details)

    if document_details.count == 1
      # Se for apenas um documento, gerar um único arquivo XLS
      xls_data = report_service.generate_xls(document_details.first)
      filename = generate_filename("documento_detalhado_#{document_details.first.id}", "xlsx")
      send_data xls_data, filename: filename, type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", disposition: 'attachment'
    else
      # Se forem múltiplos documentos, gerar um arquivo ZIP
      zip_data = report_service.generate_zip
      filename = generate_filename("relatorios_exportados", "zip")
      send_data zip_data, filename: filename, type: "application/zip", disposition: 'attachment'
    end
  end

  private

  def apply_filters(scope)
    # Filtros existentes
    scope = scope.where('dhemi >= ?', params[:start_date]) if params[:start_date].present?
    scope = scope.where('dhemi <= ?', params[:end_date]) if params[:end_date].present?
    scope = scope.joins(:emit).where('emits.xNome ILIKE ?', "%#{params[:emit_name]}%") if params[:emit_name].present?
    scope = scope.joins(:dest).where('dests.xNome ILIKE ?', "%#{params[:dest_name]}%") if params[:dest_name].present?
    scope = scope.where('vprod >= ?', params[:min_vprod]) if params[:min_vprod].present?
    scope = scope.where('vprod <= ?', params[:max_vprod]) if params[:max_vprod].present?
  
    # Filtros por Produto, NCM e CFOP diretamente no Det
    if params[:xprod].present?
      scope = scope.joins(:dets).where('dets.xProd ILIKE ?', "%#{params[:xprod]}%")
    end
  
    if params[:ncm].present?
      scope = scope.joins(:dets).where('dets.NCM ILIKE ?', "%#{params[:ncm]}%")
    end
  
    if params[:cfop].present?
      scope = scope.joins(:dets).where('dets.CFOP ILIKE ?', "%#{params[:cfop]}%")
    end
  
    scope
  end

  def set_document_detail
    @document_detail = current_user.document_details.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = 'Detalhe do documento não encontrado.'
    redirect_to reports_path
  end

  def selected_document_details
    if params[:document_detail_ids].present?
      current_user.document_details.includes(:emit, :dest, :dets).where(id: params[:document_detail_ids])
    elsif params[:id].present?
      [current_user.document_details.find_by(id: params[:id])].compact
    else
      []
    end
  end

  def generate_filename(prefix, extension)
    "#{prefix}_#{Time.now.strftime('%Y%m%d%H%M%S')}.#{extension}"
  end
end
