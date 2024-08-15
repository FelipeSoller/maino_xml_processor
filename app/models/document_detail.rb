class DocumentDetail < ApplicationRecord
  belongs_to :user
  belongs_to :document
  has_many :dets, dependent: :destroy
  has_one :emit, dependent: :destroy
  has_one :dest, dependent: :destroy

  validates :user, presence: true
end
