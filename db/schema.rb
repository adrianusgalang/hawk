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

ActiveRecord::Schema.define(version: 2019_03_15_090221) do

  create_table "alerts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "value"
    t.boolean "is_upper"
    t.integer "metric_id"
    t.integer "exclude_status", limit: 1
    t.string "date"
  end

  create_table "channels", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "telegram_channel"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "date_excs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "date"
    t.float "value"
    t.float "ratio"
    t.integer "time_unit", limit: 1
    t.string "redash_id"
    t.integer "metric_id"
    t.text "note"
  end

  create_table "metrics", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "redash_id"
    t.string "redash_title"
    t.string "time_column"
    t.string "value_column"
    t.string "dimension_column"
    t.string "dimension"
    t.integer "time_unit", limit: 1
    t.integer "value_type", limit: 1
    t.string "email"
    t.float "upper_threshold"
    t.float "lower_threshold"
    t.string "result_id"
    t.string "telegram_chanel"
    t.string "group"
    t.string "next_update"
    t.integer "schedule"
    t.integer "redash"
    t.integer "on_off", limit: 1
    t.string "last_update"
    t.integer "last_result", limit: 2
  end

end
