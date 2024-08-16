class ReportsController < ApplicationController
  include ActionView::Helpers::NumberHelper
  before_action :authenticate_user!
  before_action :set_document_detail, only: [:show, :download]

  def index
    @document_details = current_user.document_details.includes(:emit, :dest, :dets)

    @document_details = DocumentDetailFilter.new(@document_details, params).apply

    @document_details = @document_details.order(created_at: :desc).page(params[:page])
  end

  def show
    @document_detail = current_user.document_details.find(params[:id])
  end

  def export_documents
    document_details = selected_document_details

    if document_details.empty?
      redirect_to reports_path, alert: t('controllers.reports.alerts.no_documents_selected')
      return
    end

    report_service = ReportExportService.new(document_details)

    if document_details.count == 1
      xls_data = report_service.generate_xls(document_details.first)
      filename = generate_filename(t('controllers.reports.filenames.single_document'), "xlsx")
      send_data xls_data, filename: filename, type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", disposition: 'attachment'
    else
      zip_data = report_service.generate_zip
      filename = generate_filename(t('controllers.reports.filenames.multiple_documents'), "zip")
      send_data zip_data, filename: filename, type: "application/zip", disposition: 'attachment'
    end
  end

  private

  def set_document_detail
    @document_detail = current_user.document_details.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = t('controllers.reports.alerts.document_not_found')
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
