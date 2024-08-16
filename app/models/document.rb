class Document < ApplicationRecord
  belongs_to :user
  has_many :document_details, dependent: :destroy
  
  mount_uploader :file, DocumentUploader

  validates :file, presence: true

  private

  def valid_file_type
    if file.present? && !['zip', 'xml'].include?(file.file.extension.downcase)
      errors.add(:file, I18n.t('controllers.documents.alerts.invalid_file_type'))
    end
  end
end
