# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_08_15_005331) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "dests", force: :cascade do |t|
    t.string "cnpj"
    t.string "xnome"
    t.string "xlgr"
    t.string "nro"
    t.string "xbairro"
    t.string "cmun"
    t.string "xmun"
    t.string "uf"
    t.string "cep"
    t.string "cpais"
    t.string "xpais"
    t.string "indiedest"
    t.bigint "document_detail_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_detail_id"], name: "index_dests_on_document_detail_id"
  end

  create_table "dets", force: :cascade do |t|
    t.string "xprod"
    t.string "ncm"
    t.string "cfop"
    t.string "ucom"
    t.decimal "qcom"
    t.decimal "vuncom"
    t.bigint "document_detail_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_detail_id"], name: "index_dets_on_document_detail_id"
  end

  create_table "document_details", force: :cascade do |t|
    t.string "serie"
    t.string "nnf"
    t.datetime "dhemi"
    t.decimal "vipi"
    t.decimal "vpis"
    t.decimal "vcofins"
    t.decimal "vicms"
    t.decimal "vprod"
    t.decimal "vnf"
    t.bigint "document_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["document_id"], name: "index_document_details_on_document_id"
    t.index ["user_id"], name: "index_document_details_on_user_id"
  end

  create_table "documents", force: :cascade do |t|
    t.string "file"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_documents_on_user_id"
  end

  create_table "emits", force: :cascade do |t|
    t.string "cnpj"
    t.string "xnome"
    t.string "xfant"
    t.string "xlgr"
    t.string "nro"
    t.string "xcpl"
    t.string "xbairro"
    t.string "cmun"
    t.string "xmun"
    t.string "uf"
    t.string "cep"
    t.string "cpais"
    t.string "xpais"
    t.string "fone"
    t.string "ie"
    t.string "crt"
    t.bigint "document_detail_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_detail_id"], name: "index_emits_on_document_detail_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "dests", "document_details"
  add_foreign_key "dets", "document_details"
  add_foreign_key "document_details", "documents"
  add_foreign_key "document_details", "users"
  add_foreign_key "documents", "users"
  add_foreign_key "emits", "document_details"
end
