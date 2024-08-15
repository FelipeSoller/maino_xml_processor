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

  def download
    if @document_detail.nil?
      redirect_to reports_path, alert: "Documento não encontrado."
      return
    end

    p = Axlsx::Package.new
    wb = p.workbook

    # Adicionar planilha com as informações do documento
    wb.add_worksheet(name: "Detalhes do Documento") do |sheet|
      # Cabeçalhos das informações do documento
      sheet.add_row ["Informações do Documento Fiscal"]
      sheet.add_row ["Série", "NF", "Data de Emissão", "Valor do Produto", "Valor do ICMS", "Valor do IPI", "Valor do PIS", "Valor do COFINS", "Valor Total da NF"]

      # Dados do documento
      sheet.add_row [
        @document_detail.serie,
        @document_detail.nnf,
        @document_detail.dhemi.strftime("%d/%m/%Y %H:%M"),
        number_to_currency(@document_detail.vprod, unit: "R$"),
        number_to_currency(@document_detail.vicms, unit: "R$"),
        number_to_currency(@document_detail.vipi, unit: "R$"),
        number_to_currency(@document_detail.vpis, unit: "R$"),
        number_to_currency(@document_detail.vcofins, unit: "R$"),
        number_to_currency(@document_detail.vnf, unit: "R$")
      ]

      sheet.add_row []

      # Informações do emitente
      sheet.add_row ["Informações do Emitente"]
      sheet.add_row ["Nome", "CNPJ", "Endereço"]
      sheet.add_row [
        @document_detail.emit.xnome,
        @document_detail.emit.cnpj,
        "#{@document_detail.emit.xlgr}, #{@document_detail.emit.nro}, #{@document_detail.emit.xbairro}, #{@document_detail.emit.xmun}, #{@document_detail.emit.uf} - CEP: #{@document_detail.emit.cep}"
      ]

      sheet.add_row []

      # Informações do destinatário
      sheet.add_row ["Informações do Destinatário"]
      sheet.add_row ["Nome", "CNPJ", "Endereço"]
      sheet.add_row [
        @document_detail.dest.xnome,
        @document_detail.dest.cnpj,
        "#{@document_detail.dest.xlgr}, #{@document_detail.dest.nro}, #{@document_detail.dest.xbairro}, #{@document_detail.dest.xmun}, #{@document_detail.dest.uf} - CEP: #{@document_detail.dest.cep}"
      ]

      sheet.add_row []

      # Detalhes dos produtos
      sheet.add_row ["Detalhes dos Produtos"]
      sheet.add_row ["Produto", "NCM", "CFOP", "Unidade", "Quantidade", "Valor Unitário"]

      @document_detail.dets.each do |det|
        sheet.add_row [
          det.xprod,
          det.ncm,
          det.cfop,
          det.ucom,
          det.qcom,
          number_to_currency(det.vuncom, unit: "R$")
        ]
      end
    end

    # Enviar o arquivo Excel como resposta para download
    send_data p.to_stream.read, filename: "documento_detalhado_#{Time.now.strftime('%Y%m%d%H%M%S')}.xlsx", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", disposition: 'attachment'
  end

  def export
    selected_ids = params[:document_detail_ids]

    if selected_ids.blank?
      redirect_to reports_path, alert: "Nenhum relatório foi selecionado para exportação."
      return
    end

    @document_details = current_user.document_details.includes(:emit, :dest, :dets).where(id: selected_ids)

    p = Axlsx::Package.new
    wb = p.workbook

    wb.add_worksheet(name: "Relatórios") do |sheet|
      sheet.add_row ["Série", "NF", "Data de Emissão", "Emitente", "Destinatário", "Produto", "NCM", "CFOP", "Quantidade", "Valor Unitário", "Valor Total"]

      @document_details.each do |detail|
        detail.dets.each do |det|
          sheet.add_row [
            detail.serie,
            detail.nnf,
            detail.dhemi.strftime("%d/%m/%Y %H:%M"),
            detail.emit.xnome,
            detail.dest.xnome,
            det.xprod,
            det.ncm,
            det.cfop,
            det.qcom,
            det.vuncom,
            detail.vnf
          ]
        end
      end
    end

    send_data p.to_stream.read, filename: "relatorios_exportados_#{Time.now.strftime('%Y%m%d%H%M%S')}.xlsx", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", disposition: 'attachment'
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
