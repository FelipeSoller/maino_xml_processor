class CreateEmits < ActiveRecord::Migration[7.0]
  def change
    create_table :emits do |t|
      t.string :cnpj
      t.string :xnome
      t.string :xfant
      t.string :xlgr
      t.string :nro
      t.string :xcpl
      t.string :xbairro
      t.string :cmun
      t.string :xmun
      t.string :uf
      t.string :cep
      t.string :cpais
      t.string :xpais
      t.string :fone
      t.string :ie
      t.string :crt
      t.references :document_detail, null: false, foreign_key: true

      t.timestamps
    end
  end
end
