class DocumentDetail < ApplicationRecord
  belongs_to :user
  belongs_to :document
  has_many :dets, dependent: :destroy
  has_one :emit, dependent: :destroy
  has_one :dest, dependent: :destroy

  validates :user, presence: true

  scope :by_date_range, ->(start_date, end_date) {
    where(dhemi: start_date..end_date) if start_date.present? && end_date.present?
  }

  scope :by_emit_name, ->(name) {
    joins(:emit).where('emits.xnome ILIKE ?', "%#{name}%") if name.present?
  }

  scope :by_dest_name, ->(name) {
    joins(:dest).where('dests.xnome ILIKE ?', "%#{name}%") if name.present?
  }

  scope :by_vprod_range, ->(min_vprod, max_vprod) {
    where(vprod: min_vprod..max_vprod) if min_vprod.present? && max_vprod.present?
  }

  scope :by_xprod, ->(xprod) {
    joins(:dets).where('dets.xprod ILIKE ?', "%#{xprod}%") if xprod.present?
  }

  scope :by_ncm, ->(ncm) {
    joins(:dets).where('dets.ncm ILIKE ?', "%#{ncm}%") if ncm.present?
  }

  scope :by_cfop, ->(cfop) {
    joins(:dets).where('dets.cfop ILIKE ?', "%#{cfop}%") if cfop.present?
  }
end
