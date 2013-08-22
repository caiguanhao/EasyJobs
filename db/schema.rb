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

ActiveRecord::Schema.define(version: 20130822091707) do

  create_table "admins", force: true do |t|
    t.string   "email",                default: "", null: false
    t.string   "encrypted_password",   default: "", null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",        default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "auth_secret"
    t.string   "authentication_token"
  end

  add_index "admins", ["authentication_token"], name: "index_admins_on_authentication_token", unique: true
  add_index "admins", ["email"], name: "index_admins_on_email", unique: true
  add_index "admins", ["username"], name: "index_admins_on_username", unique: true

  create_table "constants", force: true do |t|
    t.string   "name"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "constants", ["name"], name: "index_constants_on_name", unique: true

  create_table "interpreters", force: true do |t|
    t.string   "path"
    t.boolean  "upload_script_first"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "interpreters", ["path"], name: "index_interpreters_on_path", unique: true

  create_table "jobs", force: true do |t|
    t.string   "name"
    t.text     "script"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "server_id"
    t.integer  "interpreter_id"
    t.float    "mean_time"
  end

  add_index "jobs", ["interpreter_id"], name: "index_jobs_on_interpreter_id"
  add_index "jobs", ["name"], name: "index_jobs_on_name", unique: true
  add_index "jobs", ["server_id"], name: "index_jobs_on_server_id"

  create_table "servers", force: true do |t|
    t.string   "name"
    t.string   "host"
    t.string   "username"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "constant_id"
  end

  add_index "servers", ["constant_id"], name: "index_servers_on_constant_id"
  add_index "servers", ["name"], name: "index_servers_on_name", unique: true

  create_table "time_stats", force: true do |t|
    t.float    "real"
    t.integer  "job_id"
    t.integer  "job_script_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "time_stats", ["job_id"], name: "index_time_stats_on_job_id"

  create_table "types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
