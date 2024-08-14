class ProcessXmlFileJob < ApplicationJob
  queue_as :file_processing

  def perform(document_id)
    document = Document.find(document_id)
    
    # Lógica para processar o arquivo XML
    xml_content = File.read(document.file.path)
    parsed_xml = Nokogiri::XML(xml_content)

    # Extração das informações relevantes
    document_number = parsed_xml.xpath("//nNF").text
    document_series = parsed_xml.xpath("//serie").text
    issue_date = parsed_xml.xpath("//dhEmi").text

    # Salvar ou processar as informações conforme a necessidade
    # Você pode criar registros em um modelo específico para armazenar as informações extraídas

    # Exemplo de criação de um registro fictício:
    DocumentDetail.create(
      document: document,
      series: document_series,
      number: document_number,
      issue_date: issue_date
    )

    # Outros processamentos, como totalizadores, impostos, etc.
  end
end
