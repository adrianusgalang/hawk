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

ActiveRecord::Schema.define(version: 2018_05_06_083644) do

  create_table "alerts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "value"
    t.boolean "is_upper"
    t.bigint "metric_id"
    t.index ["metric_id"], name: "index_alerts_on_metric_id"
  end

  create_table "metrics", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "redash_id"
    t.string "redash_title"
    t.string "time_column"
    t.string "value_column"
    t.string "time_unit"
    t.string "value_type"
    t.string "email"
    t.float "upper_threshold"
    t.float "lower_threshold"
  end

  add_foreign_key "alerts", "metrics"
end
