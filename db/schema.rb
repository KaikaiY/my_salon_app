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

ActiveRecord::Schema[7.1].define(version: 2026_04_07_043548) do
  create_table "companies", charset: "utf8mb3", force: :cascade do |t|
    t.string "company_name", null: false
    t.string "email", null: false
    t.string "phone", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invitations", charset: "utf8mb3", force: :cascade do |t|
    t.string "email", null: false
    t.string "token", null: false
    t.integer "role", null: false
    t.integer "status", default: 0, null: false
    t.datetime "expires_at", null: false
    t.datetime "accepted_at"
    t.datetime "approved_at"
    t.bigint "company_id", null: false
    t.bigint "user_id"
    t.bigint "invited_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_invitations_on_company_id"
    t.index ["email"], name: "index_invitations_on_email"
    t.index ["invited_by_id"], name: "index_invitations_on_invited_by_id"
    t.index ["token"], name: "index_invitations_on_token", unique: true
    t.index ["user_id"], name: "index_invitations_on_user_id"
  end

  create_table "time_slots", charset: "utf8mb3", force: :cascade do |t|
    t.time "start_time", null: false
    t.time "end_time", null: false
    t.bigint "treatment_day_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["treatment_day_id"], name: "index_time_slots_on_treatment_day_id"
  end

  create_table "treatment_days", charset: "utf8mb3", force: :cascade do |t|
    t.date "date", null: false
    t.integer "booking_source", null: false
    t.integer "status", default: 0, null: false
    t.text "note"
    t.bigint "company_id", null: false
    t.bigint "therapist_id"
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_treatment_days_on_company_id"
    t.index ["created_by_id"], name: "index_treatment_days_on_created_by_id"
    t.index ["therapist_id"], name: "index_treatment_days_on_therapist_id"
  end

  create_table "users", charset: "utf8mb3", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", null: false
    t.integer "role", null: false
    t.boolean "active", default: true, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "invitations", "companies"
  add_foreign_key "invitations", "users"
  add_foreign_key "invitations", "users", column: "invited_by_id"
  add_foreign_key "time_slots", "treatment_days"
  add_foreign_key "treatment_days", "companies"
  add_foreign_key "treatment_days", "users", column: "created_by_id"
  add_foreign_key "treatment_days", "users", column: "therapist_id"
  add_foreign_key "users", "companies"
end
