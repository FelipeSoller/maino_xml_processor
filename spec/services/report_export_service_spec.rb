require 'rails_helper'
require 'zip'

RSpec.describe ReportExportService, type: :service do
  let(:user) { create(:user) }
  let!(:document_detail1) { create(:document_detail, user:, dhemi: DateTime.now, vprod: 100.0) }
  let!(:document_detail2) { create(:document_detail, user:, dhemi: DateTime.now, vprod: 200.0) }
  let!(:emit) { create(:emit, document_detail: document_detail1) }
  let!(:dest) { create(:dest, document_detail: document_detail1) }
  let!(:det1) { create(:det, document_detail: document_detail1) }

  let(:service) { ReportExportService.new([document_detail1, document_detail2]) }

  describe '#generate_xls' do
    it 'generates an XLS file for a single document' do
      xls_data = service.generate_xls(document_detail1)

      expect(xls_data).not_to be_nil
      expect(xls_data).to be_a(String)
    end
  end

  describe '#generate_zip' do
    before do
      create(:emit, document_detail: document_detail2)
      create(:dest, document_detail: document_detail2)
    end

    it 'generates a ZIP file containing XLS files for multiple documents' do
      zip_data = service.generate_zip

      expect(zip_data).not_to be_nil
      expect(zip_data).to be_a(String)

      zip_files = []
      Zip::InputStream.open(StringIO.new(zip_data)) do |zip|
        while (entry = zip.get_next_entry)
          zip_files << entry.name
        end
      end

      expect(zip_files).to include("documento_detalhado_#{document_detail1.id}.xlsx")
      expect(zip_files).to include("documento_detalhado_#{document_detail2.id}.xlsx")
    end
  end
end
