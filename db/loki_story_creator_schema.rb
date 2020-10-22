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

  create_table "123", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "str"
    t.integer "int"
    t.decimal "decimal", precision: 10
    t.boolean "true"
    t.boolean "false"
    t.float "null"
    t.string "array"
    t.string "hash"
    t.date "date"
    t.time "time"
  end

  create_table "iowa_act_composite_scores_by_district_staging", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "id"
    t.integer "iter_id", default: 11
    t.timestamp "created_at", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamp "updated_at", default: -> { "CURRENT_TIMESTAMP" }
    t.integer "story_created", limit: 1
    t.string "time_frame"
    t.integer "client_id"
    t.text "client_name", size: :tiny
    t.integer "publication_id"
    t.text "publication_name", size: :tiny
    t.string "organization_ids", limit: 2000
    t.integer "period"
    t.text "districtname", size: :tiny
    t.text "class_of_curr_year", size: :tiny
    t.text "class_of_prev_year", size: :tiny
    t.text "story_table", size: :long
    t.text "publish_on", size: :tiny
    t.integer "tag_fixed", limit: 1
    t.integer "table_fixed_prod", limit: 1
    t.index ["client_id", "publication_id", "time_frame", "tag_fixed", "table_fixed_prod"], name: "story_per_publication", unique: true
    t.index ["iter_id"], name: "iter"
  end

  create_table "s1_staging", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "id"
    t.integer "iter_id", default: 14
    t.integer "client_id"
    t.string "client_name"
    t.integer "publication_id"
    t.string "publication_name"
    t.string "organization_ids", limit: 2000
    t.integer "story_created", limit: 1
    t.string "time_frame"
    t.timestamp "created_at", default: -> { "CURRENT_TIMESTAMP" }
    t.timestamp "updated_at", default: -> { "CURRENT_TIMESTAMP" }
    t.string "district"
    t.integer "superintendent_salary"
    t.integer "elementary_salary"
    t.string "high_district"
    t.integer "high_superintendent_salary"
    t.integer "high_elementary_salary"
    t.text "district_table", size: :medium
    t.text "story_table", size: :medium
    t.integer "new_column"
    t.index ["client_id", "publication_id", "time_frame", "district"], name: "story_per_publication", unique: true
  end

end
