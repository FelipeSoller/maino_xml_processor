class CreateDocumentDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :document_details do |t|
      t.string :serie
      t.string :nnf
      t.datetime :dhemi
      t.decimal :vipi
      t.decimal :vpis
      t.decimal :vcofins
      t.decimal :vicms
      t.decimal :vprod
      t.decimal :vnf
      t.references :document, null: false, foreign_key: true
      t.references :emit, null: false, foreign_key: true
      t.references :dest, null: false, foreign_key: true

      t.timestamps
    end
  end
end
