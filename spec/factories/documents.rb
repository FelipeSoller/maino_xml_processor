FactoryBot.define do
  factory :document do
    user
    file { Rack::Test::UploadedFile.new('spec/fixtures/sample.xml', 'application/xml') }
  end
end
