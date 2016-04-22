# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160422202706) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "chattels", force: :cascade do |t|
    t.integer  "proclamation_id"
    t.integer  "type"
    t.string   "description"
    t.string   "interest"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "chattels", ["interest"], name: "index_chattels_on_interest", using: :btree
  add_index "chattels", ["proclamation_id"], name: "index_chattels_on_proclamation_id", using: :btree
  add_index "chattels", ["type"], name: "index_chattels_on_type", using: :btree

  create_table "estates", force: :cascade do |t|
    t.integer  "proclamation_id"
    t.string   "cadastral_area"
    t.string   "parcel_id"
    t.string   "lv_id"
    t.string   "interest"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "estates", ["cadastral_area"], name: "index_estates_on_cadastral_area", using: :btree
  add_index "estates", ["interest"], name: "index_estates_on_interest", using: :btree
  add_index "estates", ["lv_id"], name: "index_estates_on_lv_id", using: :btree
  add_index "estates", ["parcel_id"], name: "index_estates_on_parcel_id", using: :btree
  add_index "estates", ["proclamation_id"], name: "index_estates_on_proclamation_id", using: :btree

  create_table "functionaries", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "full_name"
    t.string   "surname_at_birth"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "functionaries", ["first_name"], name: "index_functionaries_on_first_name", using: :btree
  add_index "functionaries", ["full_name"], name: "index_functionaries_on_full_name", using: :btree
  add_index "functionaries", ["last_name"], name: "index_functionaries_on_last_name", using: :btree
  add_index "functionaries", ["surname_at_birth"], name: "index_functionaries_on_surname_at_birth", using: :btree

  create_table "gains", force: :cascade do |t|
    t.integer  "proclamation_id"
    t.integer  "type"
    t.integer  "value"
    t.string   "currency"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "gains", ["currency"], name: "index_gains_on_currency", using: :btree
  add_index "gains", ["proclamation_id"], name: "index_gains_on_proclamation_id", using: :btree
  add_index "gains", ["type"], name: "index_gains_on_type", using: :btree
  add_index "gains", ["value"], name: "index_gains_on_value", using: :btree

  create_table "internal_numbers", force: :cascade do |t|
    t.integer  "functionary_id"
    t.string   "value"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "internal_numbers", ["functionary_id"], name: "index_internal_numbers_on_functionary_id", using: :btree
  add_index "internal_numbers", ["value"], name: "index_internal_numbers_on_value", using: :btree

  create_table "jobs", force: :cascade do |t|
    t.integer  "functionary_id"
    t.string   "description"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "jobs", ["description"], name: "index_jobs_on_description", using: :btree
  add_index "jobs", ["functionary_id"], name: "index_jobs_on_functionary_id", using: :btree

  create_table "proclamations", force: :cascade do |t|
    t.integer  "functionary_id"
    t.string   "global_id"
    t.string   "year"
    t.string   "adhibited_at"
    t.boolean  "satisfies_weird_conditions"
    t.boolean  "released_in_long_term"
    t.string   "entepreneur_activity"
    t.string   "administrative_functions"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "proclamations", ["adhibited_at"], name: "index_proclamations_on_adhibited_at", using: :btree
  add_index "proclamations", ["administrative_functions"], name: "index_proclamations_on_administrative_functions", using: :btree
  add_index "proclamations", ["entepreneur_activity"], name: "index_proclamations_on_entepreneur_activity", using: :btree
  add_index "proclamations", ["functionary_id"], name: "index_proclamations_on_functionary_id", using: :btree
  add_index "proclamations", ["global_id"], name: "index_proclamations_on_global_id", using: :btree
  add_index "proclamations", ["released_in_long_term"], name: "index_proclamations_on_released_in_long_term", using: :btree
  add_index "proclamations", ["satisfies_weird_conditions"], name: "index_proclamations_on_satisfies_weird_conditions", using: :btree
  add_index "proclamations", ["year"], name: "index_proclamations_on_year", using: :btree

  create_table "reimbursements", force: :cascade do |t|
    t.integer  "proclamation_id"
    t.integer  "type"
    t.integer  "value"
    t.string   "currency"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "reimbursements", ["currency"], name: "index_reimbursements_on_currency", using: :btree
  add_index "reimbursements", ["proclamation_id"], name: "index_reimbursements_on_proclamation_id", using: :btree
  add_index "reimbursements", ["type"], name: "index_reimbursements_on_type", using: :btree
  add_index "reimbursements", ["value"], name: "index_reimbursements_on_value", using: :btree

end
