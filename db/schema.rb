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

ActiveRecord::Schema[8.1].define(version: 2026_11_10_000001) do
  create_table "cash_entries", force: :cascade do |t|
    t.date "entry_on", null: false
    t.string "kind", null: false
    t.string "description", null: false
    t.string "category"
    t.string "reference"
    t.integer "amount_cents", null: false
    t.integer "offering_type_id"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_cash_entries_on_created_by_id"
    t.index ["entry_on"], name: "index_cash_entries_on_entry_on"
    t.index ["offering_type_id"], name: "index_cash_entries_on_offering_type_id"
  end

  create_table "cash_months", force: :cascade do |t|
    t.integer "year", null: false
    t.integer "month", null: false
    t.integer "brought_forward_override_cents"
    t.integer "petty_cash_cents"
    t.integer "bank_balance_cents"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["year", "month"], name: "index_cash_months_on_year_and_month", unique: true
  end

  create_table "contributions", force: :cascade do |t|
    t.integer "member_id", null: false
    t.integer "offering_type_id", null: false
    t.date "given_on", null: false
    t.integer "amount_cents", default: 0, null: false
    t.integer "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["given_on"], name: "index_contributions_on_given_on"
    t.index ["member_id", "offering_type_id", "given_on"], name: "index_contributions_unique", unique: true
    t.index ["member_id"], name: "index_contributions_on_member_id"
    t.index ["offering_type_id"], name: "index_contributions_on_offering_type_id"
    t.index ["updated_by_id"], name: "index_contributions_on_updated_by_id"
  end

  create_table "members", force: :cascade do |t|
    t.integer "section_id", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["section_id"], name: "index_members_on_section_id"
  end

  create_table "offering_types", force: :cascade do |t|
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.boolean "counts_for_ldf", default: true, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sections", force: :cascade do |t|
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "settings", force: :cascade do |t|
    t.string "church_name", default: "Altona", null: false
    t.string "currency", default: "EUR", null: false
    t.integer "collection_wday", default: 0, null: false
    t.decimal "ldf_percent", precision: 5, scale: 2, default: "10.0", null: false
    t.boolean "deduct_ldf", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "cash_entries", "offering_types"
  add_foreign_key "cash_entries", "users", column: "created_by_id"
  add_foreign_key "contributions", "members"
  add_foreign_key "contributions", "offering_types"
  add_foreign_key "contributions", "users", column: "updated_by_id"
  add_foreign_key "members", "sections"
end
