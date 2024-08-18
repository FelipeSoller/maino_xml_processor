require 'rails_helper'
require 'zip'

RSpec.describe ProcessXmlFileJob, type: :job do
  let(:user) { create(:user) }
  let(:document) { create(:document, user:) }
  let(:xml_file_path) { Rails.root.join('spec/fixtures/sample.xml') }
  let(:blob) { ActiveStorage::Blob.create_and_upload!(io: File.open(xml_file_path), filename: 'sample.xml', content_type: 'application/xml') }

  describe '#perform' do
    context 'when the file is an xml' do
      it 'processes the xml file and creates document details' do
        # Assinando o arquivo
        file_signed_id = blob.signed_id

        # Chamando o job
        expect do
          described_class.perform_now(file_signed_id, document.id)
        end.to change { DocumentDetail.count }.by(1)
                                              .and change { Emit.count }.by(1)
                                                                        .and change { Dest.count }.by(1)
                                                                                                  .and change { Det.count }.by(2)
      end
    end
  end
end
