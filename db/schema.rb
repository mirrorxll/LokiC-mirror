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

ActiveRecord::Schema.define(version: 2019_12_07_135916) do

  create_table "active_storage_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id"
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "clients", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.integer "pipeline_index"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "data_locations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "source_name"
    t.string "data_set_location"
    t.string "data_set_evaluation_document"
    t.boolean "evaluated", default: false
    t.string "scrape_dev_developer_name"
    t.string "scrape_source"
    t.string "scrape_frequency"
    t.string "data_release_frequency"
    t.boolean "cron_scraping", default: false
    t.string "scrape_developer_comments", limit: 1000
    t.string "source_key_explaining_data"
    t.string "gather_task"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_data_locations_on_user_id"
  end

  create_table "frequencies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "levels", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "photo_buckets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.integer "pipeline_index"
    t.string "name"
    t.integer "minimum_height"
    t.integer "minimum_width"
    t.string "aspect_ratio"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "projects", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.integer "pipeline_index"
    t.string "name"
    t.bigint "client_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["client_id"], name: "index_projects_on_client_id"
  end

  create_table "sections", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.integer "pipeline_index"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "staging_tables", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name"
    t.text "columns"
    t.bigint "story_type_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["story_type_id"], name: "index_staging_tables_on_story_type_id"
  end

  create_table "story_iterations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "number"
    t.boolean "populate_status", default: false
    t.boolean "create_status", default: false
    t.bigint "story_type_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["story_type_id"], name: "index_story_iterations_on_story_type_id"
  end

  create_table "story_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name"
    t.string "headline"
    t.string "teaser", limit: 500
    t.text "body", size: :medium
    t.string "description", limit: 1000
    t.date "desired_launch"
    t.date "last_launch"
    t.date "last_export"
    t.date "deadline"
    t.string "dev_status", default: "Not Started"
    t.bigint "editor_id"
    t.bigint "developer_id"
    t.bigint "data_location_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["data_location_id"], name: "index_story_types_on_data_location_id"
    t.index ["developer_id"], name: "index_story_types_on_developer_id"
    t.index ["editor_id"], name: "index_story_types_on_editor_id"
  end

  create_table "story_types__clients", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "story_type_id", null: false
    t.bigint "client_id", null: false
    t.index ["story_type_id", "client_id"], name: "index_story_types__clients_on_story_type_id_and_client_id", unique: true
  end

  create_table "story_types__frequencies", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "story_type_id", null: false
    t.bigint "frequency_id", null: false
    t.index ["frequency_id", "story_type_id"], name: "index_story_types__frequencies_on_frequency_id_and_story_type_id"
    t.index ["story_type_id"], name: "index_story_types__frequencies_on_story_type_id", unique: true
  end

  create_table "story_types__levels", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "story_type_id", null: false
    t.bigint "level_id", null: false
    t.index ["level_id", "story_type_id"], name: "index_story_types__levels_on_level_id_and_story_type_id"
    t.index ["story_type_id"], name: "index_story_types__levels_on_story_type_id", unique: true
  end

  create_table "story_types__photo_buckets", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "story_type_id", null: false
    t.bigint "photo_bucket_id", null: false
    t.index ["story_type_id", "photo_bucket_id"], name: "index_story_types__photo_buckets_story_type_id_photo_bucket_id", unique: true
  end

  create_table "story_types__sections", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "story_type_id", null: false
    t.bigint "section_id", null: false
    t.index ["story_type_id", "section_id"], name: "index_story_types__sections_on_story_type_id_and_section_id", unique: true
  end

  create_table "story_types__tags", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "story_type_id", null: false
    t.bigint "tag_id", null: false
    t.index ["story_type_id", "tag_id"], name: "index_story_types__tags_on_story_type_id_and_tag_id", unique: true
  end

  create_table "tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.integer "pipeline_index"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "account_type", null: false
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["first_name", "last_name"], name: "index_users_on_first_name_and_last_name"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
end
