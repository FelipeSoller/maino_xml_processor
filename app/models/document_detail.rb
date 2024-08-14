class DocumentDetail < ApplicationRecord
  belongs_to :document
  belongs_to :emit
  belongs_to :dest
  has_many :dets, dependent: :destroy
end
