FactoryBot.define do
  factory :det do
    document_detail
    xprod { "Produto XYZ" }
    ncm { "1234" }
    cfop { "5678" }
    ucom { "UN" }
    qcom { 10 }
    vuncom { 50.0 }
  end
end
