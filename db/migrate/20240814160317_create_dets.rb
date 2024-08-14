class CreateDets < ActiveRecord::Migration[7.0]
  def change
    create_table :dets do |t|
      t.string :xprod
      t.string :ncm
      t.string :cfop
      t.string :ucom
      t.decimal :qcom
      t.decimal :vuncom
      t.references :document_detail, null: false, foreign_key: true

      t.timestamps
    end
  end
end
