class CreateDests < ActiveRecord::Migration[7.0]
  def change
    create_table :dests do |t|
      t.string :cnpj
      t.string :xnome
      t.string :xlgr
      t.string :nro
      t.string :xbairro
      t.string :cmun
      t.string :xmun
      t.string :uf
      t.string :cep
      t.string :cpais
      t.string :xpais
      t.string :indiedest

      t.timestamps
    end
  end
end
