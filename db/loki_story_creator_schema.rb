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

  create_table "s1_staging", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "id"
    t.integer "iter_id", default: 1
    t.integer "client_id"
    t.string "client_name"
    t.integer "publication_id"
    t.string "publication_name"
    t.string "organization_ids", limit: 2000
    t.integer "story_created", limit: 1
    t.string "time_frame"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string "district"
    t.integer "superintendent_salary"
    t.integer "elementary_salary"
    t.string "high_district"
    t.integer "high_superintendent_salary"
    t.integer "high_elementary_salary"
    t.text "district_table", size: :medium
    t.text "story_table", size: :medium
  end

end
