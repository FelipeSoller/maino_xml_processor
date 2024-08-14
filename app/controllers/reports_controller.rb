class ReportsController < ApplicationController
  before_action :authenticate_user!

  def index
    @document_details = DocumentDetail.all.includes(:emit, :dest, :dets)
  end

  def show
    @document_detail = DocumentDetail.find(params[:id])
  end
end
