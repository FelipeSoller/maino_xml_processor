FactoryBot.define do
  factory :dest do
    document_detail
    cnpj { "98765432101234" }
    xnome { "Destinatário ABC" }
  end
end
