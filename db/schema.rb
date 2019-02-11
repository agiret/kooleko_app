# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_02_11_181334) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "housings", force: :cascade do |t|
    t.integer "surface_area"
    t.string "heat_system"
    t.string "hot_water_system"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "enedis_usage_point_id"
    t.string "address_street"
    t.string "address_locality"
    t.string "address_postal_code"
    t.string "address_insee_code"
    t.string "address_city"
    t.string "address_country"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "housing_id"
    t.integer "onboarding_step"
    t.integer "enedis_state"
    t.string "enedis_access_token", default: "", null: false
    t.string "enedis_refresh_token", default: "", null: false
    t.string "firstname"
    t.string "lastname"
    t.string "phone"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["housing_id"], name: "index_users_on_housing_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "users", "housings"
end
