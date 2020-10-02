# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_10_02_070426) do

  create_table "clients_reports", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
  end

  create_table "report_developers_productions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "iteration_id"
    t.datetime "date_export"
    t.index ["account_id"], name: "index_developer_productions_on_account_id"
    t.index ["iteration_id"], name: "index_developer_productions_on_iteration_id"
  end

  create_table "report_tracking_hours", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "type_of_work_id"
    t.bigint "clients_report_id"
    t.decimal "hours", precision: 2, scale: 2
    t.datetime "date"
    t.string "comment", limit: 2000
    t.index ["account_id"], name: "index_report_tracking_hours_on_account_id"
    t.index ["clients_report_id"], name: "index_report_tracking_hours_on_clients_report_id"
    t.index ["type_of_work_id"], name: "index_report_tracking_hours_on_type_of_work_id"
  end

  create_table "reviews", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "report_type"
    t.text "table"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "type_of_works", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
  end

end
