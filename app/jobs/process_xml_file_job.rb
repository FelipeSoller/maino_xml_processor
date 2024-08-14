class ProcessXmlFileJob < ApplicationJob
  queue_as :file_processing

  def perform(document_id)
    document = Document.find(document_id)
    
    # Ler o conteúdo do arquivo XML
    xml_content = File.read(document.file.path)
    
    # Parsear o XML e definir o namespace
    parsed_xml = Nokogiri::XML(xml_content)
    namespaces = { 'nfe' => 'http://www.portalfiscal.inf.br/nfe' }
    
    # Extração das informações do emitente (emit)
    emit_element = parsed_xml.at_xpath("//nfe:emit", namespaces)
    emit = Emit.create!(
      cnpj: emit_element.at_xpath("nfe:CNPJ", namespaces).text,
      xnome: emit_element.at_xpath("nfe:xNome", namespaces).text,
      xfant: emit_element.at_xpath("nfe:xFant", namespaces).text,
      xlgr: emit_element.at_xpath("nfe:enderEmit/nfe:xLgr", namespaces).text,
      nro: emit_element.at_xpath("nfe:enderEmit/nfe:nro", namespaces).text,
      xcpl: emit_element.at_xpath("nfe:enderEmit/nfe:xCpl", namespaces).text,
      xbairro: emit_element.at_xpath("nfe:enderEmit/nfe:xBairro", namespaces).text,
      cmun: emit_element.at_xpath("nfe:enderEmit/nfe:cMun", namespaces).text,
      xmun: emit_element.at_xpath("nfe:enderEmit/nfe:xMun", namespaces).text,
      uf: emit_element.at_xpath("nfe:enderEmit/nfe:UF", namespaces).text,
      cep: emit_element.at_xpath("nfe:enderEmit/nfe:CEP", namespaces).text,
      cpais: emit_element.at_xpath("nfe:enderEmit/nfe:cPais", namespaces).text,
      xpais: emit_element.at_xpath("nfe:enderEmit/nfe:xPais", namespaces).text,
      fone: emit_element.at_xpath("nfe:enderEmit/nfe:fone", namespaces).text,
      ie: emit_element.at_xpath("nfe:IE", namespaces).text,
      crt: emit_element.at_xpath("nfe:CRT", namespaces).text
    )

    # Extração das informações do destinatário (dest)
    dest_element = parsed_xml.at_xpath("//nfe:dest", namespaces)
    dest = Dest.create!(
      cnpj: dest_element.at_xpath("nfe:CNPJ", namespaces).text,
      xnome: dest_element.at_xpath("nfe:xNome", namespaces).text,
      xlgr: dest_element.at_xpath("nfe:enderDest/nfe:xLgr", namespaces).text,
      nro: dest_element.at_xpath("nfe:enderDest/nfe:nro", namespaces).text,
      xbairro: dest_element.at_xpath("nfe:enderDest/nfe:xBairro", namespaces).text,
      cmun: dest_element.at_xpath("nfe:enderDest/nfe:cMun", namespaces).text,
      xmun: dest_element.at_xpath("nfe:enderDest/nfe:xMun", namespaces).text,
      uf: dest_element.at_xpath("nfe:enderDest/nfe:UF", namespaces).text,
      cep: dest_element.at_xpath("nfe:enderDest/nfe:CEP", namespaces).text,
      cpais: dest_element.at_xpath("nfe:enderDest/nfe:cPais", namespaces).text,
      xpais: dest_element.at_xpath("nfe:enderDest/nfe:xPais", namespaces).text,
      indiedest: dest_element.at_xpath("nfe:indIEDest", namespaces).text
    )

    # Extração das informações do documento fiscal (DocumentDetail)
    document_detail = DocumentDetail.create!(
      document: document,
      serie: parsed_xml.at_xpath("//nfe:ide/nfe:serie", namespaces).text,
      nnf: parsed_xml.at_xpath("//nfe:ide/nfe:nNF", namespaces).text,
      dhemi: parsed_xml.at_xpath("//nfe:ide/nfe:dhEmi", namespaces).text,
      vipi: parsed_xml.at_xpath("//nfe:ICMSTot/nfe:vIPI", namespaces).text.to_d,
      vpis: parsed_xml.at_xpath("//nfe:ICMSTot/nfe:vPIS", namespaces).text.to_d,
      vcofins: parsed_xml.at_xpath("//nfe:ICMSTot/nfe:vCOFINS", namespaces).text.to_d,
      vicms: parsed_xml.at_xpath("//nfe:ICMSTot/nfe:vICMS", namespaces).text.to_d,
      vprod: parsed_xml.at_xpath("//nfe:ICMSTot/nfe:vProd", namespaces).text.to_d,
      vnf: parsed_xml.at_xpath("//nfe:ICMSTot/nfe:vNF", namespaces).text.to_d,
      emit: emit,
      dest: dest
    )

    # Extração das informações dos produtos (det)
    parsed_xml.xpath("//nfe:det", namespaces).each do |det_element|
      Det.create!(
        document_detail: document_detail,
        xprod: det_element.at_xpath("nfe:prod/nfe:xProd", namespaces).text,
        ncm: det_element.at_xpath("nfe:prod/nfe:NCM", namespaces).text,
        cfop: det_element.at_xpath("nfe:prod/nfe:CFOP", namespaces).text,
        ucom: det_element.at_xpath("nfe:prod/nfe:uCom", namespaces).text,
        qcom: det_element.at_xpath("nfe:prod/nfe:qCom", namespaces).text.to_d,
        vuncom: det_element.at_xpath("nfe:prod/nfe:vUnCom", namespaces).text.to_d
      )
    end
  end
end
