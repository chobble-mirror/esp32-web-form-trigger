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

ActiveRecord::Schema[8.0].define(version: 2025_05_12_153413) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "devices", id: { type: :string, limit: 12 }, force: :cascade do |t|
    t.string "name", null: false
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "archived", default: false
    t.index ["archived"], name: "index_devices_on_archived"
  end

  create_table "forms", force: :cascade do |t|
    t.string "background_color"
    t.string "text_color"
    t.string "button_color"
    t.string "button_text_color"
    t.string "button_text"
    t.text "header_text"
    t.boolean "enable_name", default: true
    t.boolean "enable_email_address", default: true
    t.boolean "enable_phone", default: false
    t.boolean "enable_address", default: false
    t.boolean "enable_postcode", default: false
    t.text "terms_and_conditions"
    t.text "thank_you_text"
    t.string "target_email_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
  end

  create_table "submissions", force: :cascade do |t|
    t.integer "form_id", null: false
    t.string "device_id", limit: 12
    t.string "name"
    t.string "email_address"
    t.string "phone"
    t.text "address"
    t.string "postcode"
    t.boolean "credit_claimed", default: false
    t.string "email_status", default: "pending"
    t.datetime "emailed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id", "credit_claimed"], name: "index_submissions_on_device_and_credit"
    t.index ["device_id"], name: "index_submissions_on_device_id"
    t.index ["form_id"], name: "index_submissions_on_form_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_active_at"
    t.index ["email"], name: "index_users_on_email"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "submissions", "devices"
  add_foreign_key "submissions", "forms"
end
