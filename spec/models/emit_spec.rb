require 'rails_helper'

RSpec.describe Emit, type: :model do
  let(:document_detail) { create(:document_detail) }

  describe 'associations' do
    it 'belongs to document_detail' do
      association = Emit.reflect_on_association(:document_detail)
      expect(association.macro).to eq(:belongs_to)
    end
  end
end
