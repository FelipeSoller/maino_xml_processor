class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_document_detail, only: [:show]

  def index
    @document_details = current_user.document_details.includes(:emit, :dest, :dets).order(created_at: :desc).page(params[:page])
  end

  def show
    @document_detail = current_user.document_details.find(params[:id])
  end

  private

  def set_document_detail
    @document_detail = current_user.document_details.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = 'Detalhe do documento não encontrado.'
    redirect_to reports_path
  end
end
