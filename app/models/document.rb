class Document < ApplicationRecord
  belongs_to :user
  has_many :document_details, dependent: :destroy
  
  has_many_attached :files
end
