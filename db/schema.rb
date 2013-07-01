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

ActiveRecord::Schema.define(version: 20130701065340) do

  create_table "constants", force: true do |t|
    t.string   "name"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "interpreters", force: true do |t|
    t.string   "path"
    t.boolean  "upload_script_first"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jobs", force: true do |t|
    t.string   "name"
    t.text     "script"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "server_id"
    t.integer  "interpreter_id"
  end

  create_table "servers", force: true do |t|
    t.string   "name"
    t.string   "host"
    t.string   "username"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "time_stats", force: true do |t|
    t.float    "real"
    t.integer  "job_id"
    t.integer  "job_script_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "time_stats", ["job_id"], name: "index_time_stats_on_job_id"

end
