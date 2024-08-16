FactoryBot.define do
  factory :document_detail do
    user
    document
    serie { "1" }
    nnf { "123456" }
    dhemi { DateTime.now }
    vprod { 100.00 }
  end
end
