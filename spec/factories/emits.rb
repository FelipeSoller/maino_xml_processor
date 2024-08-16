FactoryBot.define do
  factory :emit do
    document_detail
    cnpj { "12345678901234" }
    xnome { "Emitente XYZ" }
  end
end
