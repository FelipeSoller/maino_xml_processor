class Dest < ApplicationRecord
  has_many :document_details, dependent: :destroy
end
