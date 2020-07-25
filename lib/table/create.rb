# frozen_string_literal: true

module Table
  module Create
    def create(t_name)
      loki_story_creator do
        a_r_m.create_table(t_name) do |t|
          t.integer  :client_ids903_staging
          t.string   :client_name
          t.integer  :publication_id
          t.string   :publication_name
          t.string   :organization_ids, limit: 2000
          t.boolean  :story_created, default: false
          t.string   :time_frame
        end
      end

      timestamps(t_name)
    end

    def timestamps(t_name)
      loki_story_creator do
        a_r_m.add_column t_name, :created_at, :datetime unless a_r_m.column_exists?(t_name, :created_at)
        a_r_m.add_column t_name, :updated_at, :datetime unless a_r_m.column_exists?(t_name, :updated_at)

        cr_at_query = created_at_default_value_query(t_name)
        a_r_b_conn.exec_query(cr_at_query)
        upd_at_query = updated_at_default_value_query(t_name)
        a_r_b_conn.exec_query(upd_at_query)
      end
    end

    def iter_id_column(t_name, iter_id)
      loki_story_creator do
        if iter_id_present?(t_name)
          a_r_m.change_column_default(t_name, :iter_id, iter_id)
        else
          a_r_m.add_column(t_name, :iter_id, :integer, default: iter_id, after: :id)
          a_r_m.add_index(t_name, :iter_id, name: :iter)
        end
      end
    end

    def iter_id_present?(t_name)
      a_r_m.columns(t_name).find { |c| c.name.eql?('iter_id') }
    end
  end
end
