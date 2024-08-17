require 'zip'

class ProcessXmlFileJob < ApplicationJob
  queue_as :file_processing

  def perform(file_signed_id, document_id)
    document = Document.find(document_id)
    file = ActiveStorage::Blob.find_signed(file_signed_id)

    if file.filename.extension.downcase == 'zip'
      Rails.logger.info "Processando arquivo ZIP: #{file.filename}"
      process_zip_file(file, document)
    else
      Rails.logger.info "Processando arquivo XML individual: #{file.filename}"
      process_xml_file(file, document)
    end
  end

  private

  def process_zip_file(file, document)
    Rails.logger.info "Iniciando o processamento do ZIP para o documento #{document.id}"
    temp_file = file.download
    Zip::File.open_buffer(temp_file) do |zip_file|
      zip_file.each do |entry|
        next unless entry.file? && entry.name.downcase.end_with?('.xml')

        Rails.logger.info "Processando arquivo XML no ZIP: #{entry.name}"
        xml_content = entry.get_input_stream.read
        parsed_xml = Nokogiri::XML(xml_content)
        process_parsed_xml(parsed_xml, document)
      end
    end
  rescue StandardError => e
    Rails.logger.error "Erro ao processar o arquivo ZIP: #{e.message}"
  end

  def process_xml_file(file, document)
    Rails.logger.info "Processando arquivo XML individual: #{file.filename}"
    xml_content = file.download
    parsed_xml = Nokogiri::XML(xml_content)
    process_parsed_xml(parsed_xml, document)
  end

  def process_parsed_xml(parsed_xml, document)
    namespaces = { 'nfe' => 'http://www.portalfiscal.inf.br/nfe' }

    emit_element = parsed_xml.at_xpath("//nfe:emit", namespaces)
    dest_element = parsed_xml.at_xpath("//nfe:dest", namespaces)
    ide_element = parsed_xml.at_xpath("//nfe:ide", namespaces)
    
    unless emit_element && dest_element && ide_element
      logger.error "Missing required elements in XML. Skipping processing."
      return
    end

    document_detail = DocumentDetail.create!(
      document: document,
      user: document.user,
      serie: ide_element.at_xpath("nfe:serie", namespaces)&.text,
      nnf: ide_element.at_xpath("nfe:nNF", namespaces)&.text,
      dhemi: ide_element.at_xpath("nfe:dhEmi", namespaces)&.text,
      vipi: parsed_xml.at_xpath("//nfe:ICMSTot/nfe:vIPI", namespaces)&.text.to_d,
      vpis: parsed_xml.at_xpath("//nfe:ICMSTot/nfe:vPIS", namespaces)&.text.to_d,
      vcofins: parsed_xml.at_xpath("//nfe:ICMSTot/nfe:vCOFINS", namespaces)&.text.to_d,
      vicms: parsed_xml.at_xpath("//nfe:ICMSTot/nfe:vICMS", namespaces)&.text.to_d,
      vprod: parsed_xml.at_xpath("//nfe:ICMSTot/nfe:vProd", namespaces)&.text.to_d,
      vnf: parsed_xml.at_xpath("//nfe:ICMSTot/nfe:vNF", namespaces)&.text.to_d,
    )

    Emit.create!(
      document_detail: document_detail,
      cnpj: emit_element.at_xpath("nfe:CNPJ", namespaces)&.text,
      xnome: emit_element.at_xpath("nfe:xNome", namespaces)&.text,
      xfant: emit_element.at_xpath("nfe:xFant", namespaces)&.text,
      xlgr: emit_element.at_xpath("nfe:enderEmit/nfe:xLgr", namespaces)&.text,
      nro: emit_element.at_xpath("nfe:enderEmit/nfe:nro", namespaces)&.text,
      xcpl: emit_element.at_xpath("nfe:enderEmit/nfe:xCpl", namespaces)&.text,
      xbairro: emit_element.at_xpath("nfe:enderEmit/nfe:xBairro", namespaces)&.text,
      cmun: emit_element.at_xpath("nfe:enderEmit/nfe:cMun", namespaces)&.text,
      xmun: emit_element.at_xpath("nfe:enderEmit/nfe:xMun", namespaces)&.text,
      uf: emit_element.at_xpath("nfe:enderEmit/nfe:UF", namespaces)&.text,
      cep: emit_element.at_xpath("nfe:enderEmit/nfe:CEP", namespaces)&.text,
      cpais: emit_element.at_xpath("nfe:enderEmit/nfe:cPais", namespaces)&.text,
      xpais: emit_element.at_xpath("nfe:enderEmit/nfe:xPais", namespaces)&.text,
      fone: emit_element.at_xpath("nfe:enderEmit/nfe:fone", namespaces)&.text,
      ie: emit_element.at_xpath("nfe:IE", namespaces)&.text,
      crt: emit_element.at_xpath("nfe:CRT", namespaces)&.text
    )

    Dest.create!(
      document_detail: document_detail,
      cnpj: dest_element.at_xpath("nfe:CNPJ", namespaces)&.text,
      xnome: dest_element.at_xpath("nfe:xNome", namespaces)&.text,
      xlgr: dest_element.at_xpath("nfe:enderDest/nfe:xLgr", namespaces)&.text,
      nro: dest_element.at_xpath("nfe:enderDest/nfe:nro", namespaces)&.text,
      xbairro: dest_element.at_xpath("nfe:enderDest/nfe:xBairro", namespaces)&.text,
      cmun: dest_element.at_xpath("nfe:enderDest/nfe:cMun", namespaces)&.text,
      xmun: dest_element.at_xpath("nfe:enderDest/nfe:xMun", namespaces)&.text,
      uf: dest_element.at_xpath("nfe:enderDest/nfe:UF", namespaces)&.text,
      cep: dest_element.at_xpath("nfe:enderDest/nfe:CEP", namespaces)&.text,
      cpais: dest_element.at_xpath("nfe:enderDest/nfe:cPais", namespaces)&.text,
      xpais: dest_element.at_xpath("nfe:enderDest/nfe:xPais", namespaces)&.text,
      indiedest: dest_element.at_xpath("nfe:indIEDest", namespaces)&.text
    )

    parsed_xml.xpath("//nfe:det", namespaces).each do |det_element|
      Det.create!(
        document_detail: document_detail,
        xprod: det_element.at_xpath("nfe:prod/nfe:xProd", namespaces)&.text,
        ncm: det_element.at_xpath("nfe:prod/nfe:NCM", namespaces)&.text,
        cfop: det_element.at_xpath("nfe:prod/nfe:CFOP", namespaces)&.text,
        ucom: det_element.at_xpath("nfe:prod/nfe:uCom", namespaces)&.text,
        qcom: det_element.at_xpath("nfe:prod/nfe:qCom", namespaces)&.text.to_d,
        vuncom: det_element.at_xpath("nfe:prod/nfe:vUnCom", namespaces)&.text.to_d
      )
    end
  end
end
