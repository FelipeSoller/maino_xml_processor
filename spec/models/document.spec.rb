require 'rails_helper'

RSpec.describe Document, type: :model do
  let(:user) { create(:user) }

  describe 'associations' do
    it 'belongs to user' do
      association = Document.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end

    it 'has many document_details with dependent destroy' do
      association = Document.reflect_on_association(:document_details)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end
  end

  describe 'validations' do
    it 'validates presence of file' do
      document = Document.new(user:, file: nil)
      expect(document).not_to be_valid
      expect(document.errors[:file]).to include("can't be blank")
    end

    it 'validates file type is either zip or xml' do
      invalid_file = Rack::Test::UploadedFile.new('spec/fixtures/sample.txt', 'text/plain')
      document = Document.new(user:, file: invalid_file)
      expect(document).not_to be_valid
      expect(document.errors[:file]).to include(I18n.t('controllers.documents.alerts.invalid_file_type'))
    end

    it 'is valid with an xml file' do
      valid_file = Rack::Test::UploadedFile.new('spec/fixtures/sample.xml', 'application/xml')
      document = Document.new(user:, file: valid_file)
      expect(document).to be_valid
    end

    it 'is valid with a zip file' do
      valid_file = Rack::Test::UploadedFile.new('spec/fixtures/sample.zip', 'application/zip')
      document = Document.new(user:, file: valid_file)
      expect(document).to be_valid
    end
  end

  describe 'callbacks' do
    it 'calls valid_file_type before saving' do
      document = build(:document, user:)
      expect(document).to receive(:valid_file_type)
      document.save
    end
  end

  describe 'mount_uploader' do
    it 'mounts the DocumentUploader to the file attribute' do
      expect(Document.uploaders[:file]).to eq(DocumentUploader)
    end
  end
end
