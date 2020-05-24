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

ActiveRecord::Schema.define(version: 2020_05_23_105723) do

  create_table "account_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "permissions", limit: 5000
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "account_type_id"
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_type_id"], name: "index_accounts_on_account_type_id"
    t.index ["email"], name: "index_accounts_on_email", unique: true
    t.index ["first_name", "last_name"], name: "index_accounts_on_first_name_and_last_name"
    t.index ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true
  end

  create_table "active_storage_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id"
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "authors", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "clients", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "author_id"
    t.integer "pl_identifier"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_clients_on_author_id"
  end

  create_table "clients_sections", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.bigint "section_id", null: false
    t.index ["client_id", "section_id"], name: "index_clients_sections_on_client_id_and_section_id", unique: true
  end

  create_table "clients_story_types", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "story_type_id", null: false
    t.bigint "client_id", null: false
    t.index ["story_type_id", "client_id"], name: "index_clients_story_types_on_story_type_id_and_client_id", unique: true
  end

  create_table "columns", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "staging_table_id"
    t.string "list", limit: 10000
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["staging_table_id"], name: "index_columns_on_staging_table_id"
  end

  create_table "data_sets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "evaluator_id"
    t.bigint "src_release_frequency_id"
    t.bigint "src_scrape_frequency_id"
    t.string "name"
    t.string "src_address"
    t.string "src_explaining_data"
    t.string "src_release_frequency_manual"
    t.string "src_scrape_frequency_manual"
    t.boolean "cron_scraping", default: false
    t.string "location"
    t.string "evaluation_document"
    t.boolean "evaluated", default: false
    t.datetime "evaluated_at"
    t.string "gather_task"
    t.string "scrape_developer"
    t.string "comment", limit: 1000
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_data_sets_on_account_id"
    t.index ["evaluator_id"], name: "index_data_sets_on_evaluator_id"
    t.index ["src_release_frequency_id"], name: "index_data_sets_on_src_release_frequency_id"
    t.index ["src_scrape_frequency_id"], name: "index_data_sets_on_src_scrape_frequency_id"
  end

  create_table "export_configurations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "story_type_id"
    t.bigint "publication_id"
    t.integer "production_job_item"
    t.integer "staging_job_item"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["publication_id"], name: "index_export_configurations_on_publication_id"
    t.index ["story_type_id", "publication_id"], name: "export_config_unique_index", unique: true
    t.index ["story_type_id"], name: "index_export_configurations_on_story_type_id"
  end

  create_table "frequencies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "indices", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "staging_table_id"
    t.string "list", limit: 1000
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["staging_table_id"], name: "index_indices_on_staging_table_id"
  end

  create_table "iterations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "story_type_id"
    t.boolean "population"
    t.string "population_args"
    t.boolean "export_configurations"
    t.boolean "story_samples"
    t.string "story_sample_ids"
    t.boolean "creation"
    t.boolean "export"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["story_type_id"], name: "index_iterations_on_story_type_id"
  end

  create_table "outputs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "headline", limit: 300
    t.string "teaser", limit: 500
    t.text "body", limit: 16777215
  end

  create_table "photo_buckets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "pl_identifier"
    t.string "name"
    t.integer "minimum_height"
    t.integer "minimum_width"
    t.string "aspect_ratio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "publications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "client_id"
    t.integer "pl_identifier"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_publications_on_client_id"
  end

  create_table "samples", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "iteration_id"
    t.bigint "export_configuration_id"
    t.bigint "publication_id"
    t.bigint "output_id"
    t.bigint "time_frame_id"
    t.integer "staging_row_id"
    t.date "published_at"
    t.string "organization_ids", limit: 1000
    t.integer "pl_production_id"
    t.integer "pl_staging_id"
    t.date "exported_at"
    t.boolean "backdated", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["export_configuration_id"], name: "index_samples_on_export_configuration_id"
    t.index ["iteration_id"], name: "index_samples_on_iteration_id"
    t.index ["output_id"], name: "index_samples_on_output_id"
    t.index ["publication_id"], name: "index_samples_on_publication_id"
    t.index ["time_frame_id"], name: "index_samples_on_time_frame_id"
  end

  create_table "sections", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "pl_identifier"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "slack_accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "account_id"
    t.string "identifier"
    t.string "user_name"
    t.boolean "deleted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_slack_accounts_on_account_id"
    t.index ["identifier"], name: "index_slack_accounts_on_identifier", unique: true
  end

  create_table "staging_tables", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "story_type_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["story_type_id"], name: "index_staging_tables_on_story_type_id"
  end

  create_table "statuses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "story_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "editor_id"
    t.bigint "developer_id"
    t.bigint "data_set_id"
    t.bigint "status_id"
    t.bigint "frequency_id"
    t.bigint "photo_bucket_id"
    t.bigint "tag_id"
    t.string "name"
    t.datetime "last_export"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_set_id"], name: "index_story_types_on_data_set_id"
    t.index ["developer_id"], name: "index_story_types_on_developer_id"
    t.index ["editor_id"], name: "index_story_types_on_editor_id"
    t.index ["frequency_id"], name: "index_story_types_on_frequency_id"
    t.index ["name"], name: "index_story_types_on_name", unique: true
    t.index ["photo_bucket_id"], name: "index_story_types_on_photo_bucket_id"
    t.index ["status_id"], name: "index_story_types_on_status_id"
    t.index ["tag_id"], name: "index_story_types_on_tag_id"
  end

  create_table "tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "pl_identifier"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "templates", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "story_type_id"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["story_type_id"], name: "index_templates_on_story_type_id"
  end

  create_table "time_frames", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "frame"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
end
