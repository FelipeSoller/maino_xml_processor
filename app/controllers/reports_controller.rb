class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_document_detail, only: [:show]

  def index
    @document_details = current_user.document_details.includes(:emit, :dest, :dets)
    
    @document_details = apply_filters(@document_details)
    
    @document_details = @document_details.order(created_at: :desc).page(params[:page])
  end

  def show
    @document_detail = current_user.document_details.find(params[:id])
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
end
