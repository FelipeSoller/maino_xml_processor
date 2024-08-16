require 'rails_helper'
require 'zip'

RSpec.describe ProcessXmlFileJob, type: :job do
  let(:user) { create(:user) }
  let(:document) { create(:document, user:) }

  describe '#perform' do
    context 'when the file is an xml' do
      before do
        allow(document.file).to receive(:file).and_return(double(extension: 'xml'))
        allow(File).to receive(:read).and_return(File.read(Rails.root.join('spec/fixtures/sample.xml')))
      end

      it 'processes the xml file and creates document details' do
        expect { described_class.perform_now(document.id) }
          .to change { DocumentDetail.count }.by(1)
          .and change { Emit.count }.by(1)
          .and change { Dest.count }.by(1)
          .and change { Det.count }.by(2)
      end
    end
  end
end
