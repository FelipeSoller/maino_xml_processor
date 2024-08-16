class Document < ApplicationRecord
  belongs_to :user
  has_many :document_details, dependent: :destroy
  
  mount_uploader :file, DocumentUploader

  validates :file, presence: true
end
