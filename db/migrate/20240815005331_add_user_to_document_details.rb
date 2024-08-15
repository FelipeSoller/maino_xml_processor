class AddUserToDocumentDetails < ActiveRecord::Migration[7.0]
  def change
    add_reference :document_details, :user, null: false, foreign_key: true
  end
end
