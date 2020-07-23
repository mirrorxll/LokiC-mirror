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

  create_table "s903_staging", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "id"
    t.integer "iter_id", default: 1
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer "client_id"
    t.text "client_name", size: :tiny
    t.integer "publication_id"
    t.text "publication_name", size: :tiny
    t.integer "story_created", limit: 1
    t.text "time_frame", size: :tiny
    t.string "district"
    t.integer "curr_sal_elem_princ"
    t.integer "curr_sal_high_princ"
    t.integer "prev_sal_elem_princ"
    t.text "publish_on", size: :tiny
    t.decimal "column_16", precision: 10, scale: 2
    t.index ["iter_id"], name: "iter"
  end

end
