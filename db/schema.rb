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

ActiveRecord::Schema.define(version: 20131012202722) do

  create_table "posts", force: true do |t|
    t.string   "title",       null: false
    t.string   "short_url",   null: false
    t.string   "description"
    t.text     "content",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["content"], name: "post_content_index"
  add_index "posts", ["short_url"], name: "post_short_url_uniqueness", unique: true
  add_index "posts", ["title"], name: "post_title_uniqueness", unique: true

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", force: true do |t|
    t.string "name"
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true

  create_table "users", force: true do |t|
    t.string   "login",                         null: false
    t.string   "email",                         null: false
    t.string   "crypted_password",              null: false
    t.string   "password_salt",                 null: false
    t.string   "persistence_token",             null: false
    t.integer  "login_count",       default: 0, null: false
    t.datetime "last_login_at"
    t.string   "last_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end