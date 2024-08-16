# app/services/report_export_service.rb
require 'zip'

class ReportExportService
  include ActionView::Helpers::NumberHelper

  def initialize(document_details)
    @document_details = document_details
  end

  # Método para gerar o arquivo XLS para um único documento
  def generate_xls(detail)
    p = Axlsx::Package.new
    wb = p.workbook

    wb.add_worksheet(name: "Detalhes do Documento") do |sheet|
      sheet.add_row ["Informações do Documento Fiscal"]
      sheet.add_row ["Série", "NF", "Data de Emissão", "Valor do Produto", "Valor do ICMS", "Valor do IPI", "Valor do PIS", "Valor do COFINS", "Valor Total da NF"]

      sheet.add_row [
        detail.serie,
        detail.nnf,
        detail.dhemi.strftime("%d/%m/%Y %H:%M"),
        number_to_currency(detail.vprod, unit: "R$"),
        number_to_currency(detail.vicms, unit: "R$"),
        number_to_currency(detail.vipi, unit: "R$"),
        number_to_currency(detail.vpis, unit: "R$"),
        number_to_currency(detail.vcofins, unit: "R$"),
        number_to_currency(detail.vnf, unit: "R$")
      ]

      add_emitente(sheet, detail.emit)
      add_destinatario(sheet, detail.dest)
      add_dets(sheet, detail.dets)
    end

    p.to_stream.read
  end

  # Método para gerar um arquivo ZIP contendo vários arquivos XLS
  def generate_zip
    zip_data = Zip::OutputStream.write_buffer do |zip|
      @document_details.each do |detail|
        xls_data = generate_xls(detail)
        zip.put_next_entry "documento_detalhado_#{detail.id}.xlsx"
        zip.write xls_data
      end
    end

    zip_data.rewind
    zip_data.read
  end

  private

  def add_emitente(sheet, emit)
    sheet.add_row []
    sheet.add_row ["Informações do Emitente"]
    sheet.add_row ["Nome", "CNPJ", "Endereço"]
    sheet.add_row [
      emit.xnome,
      emit.cnpj,
      "#{emit.xlgr}, #{emit.nro}, #{emit.xbairro}, #{emit.xmun}, #{emit.uf} - CEP: #{emit.cep}"
    ]
  end

  def add_destinatario(sheet, dest)
    sheet.add_row []
    sheet.add_row ["Informações do Destinatário"]
    sheet.add_row ["Nome", "CNPJ", "Endereço"]
    sheet.add_row [
      dest.xnome,
      dest.cnpj,
      "#{dest.xlgr}, #{dest.nro}, #{dest.xbairro}, #{dest.xmun}, #{dest.uf} - CEP: #{dest.cep}"
    ]
  end

  def add_dets(sheet, dets)
    sheet.add_row []
    sheet.add_row ["Detalhes dos Produtos"]
    sheet.add_row ["Produto", "NCM", "CFOP", "Unidade", "Quantidade", "Valor Unitário"]

    dets.each do |det|
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
end
