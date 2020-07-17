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

ActiveRecord::Schema.define(version: 0) do

  create_table "s1_staging", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "iter_id", default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "client_id"
    t.string "client_name"
    t.integer "publication_id"
    t.string "publication_name"
    t.string "organization_ids", limit: 2000
    t.boolean "story_created", default: false
    t.string "time_frame"
    t.index ["iter_id"], name: "iter"
  end

  create_table "s4_staging", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "iter_id", default: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "client_id"
    t.string "client_name"
    t.integer "publication_id"
    t.string "publication_name"
    t.string "organization_ids", limit: 2000
    t.boolean "story_created", default: false
    t.string "time_frame"
    t.text "story_table"
    t.integer "year"
    t.string "month", limit: 20
    t.index ["client_id", "publication_id", "year", "month"], name: "story_per_publication", unique: true
    t.index ["iter_id"], name: "iter"
  end

end
