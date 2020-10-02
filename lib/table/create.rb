# frozen_string_literal: true

module Table
  module Create
    def create(t_name)
      loki_story_creator { a_r_m.create_table(t_name) }
      nil
    end

    def add_default_columns(t_name)
      loki_story_creator do
        columns = a_r_m.columns(t_name)

        unless columns.find { |c| c.name.eql?('client_id') }
          a_r_m.add_column(t_name, :client_id, :integer, after: :iter_id)
        end

        unless columns.find { |c| c.name.eql?('client_name') }
          a_r_m.add_column(t_name, :client_name, :string, after: :client_id)
        end

        unless columns.find { |c| c.name.eql?('publication_id') }
          a_r_m.add_column(t_name, :publication_id, :integer, after: :client_name)
        end

        unless columns.find { |c| c.name.eql?('publication_name') }
          a_r_m.add_column(t_name, :publication_name, :string, after: :publication_id)
        end

        if columns.find { |c| c.name.eql?('organization_id') }
          a_r_m.rename_column(t_name, :organization_id, :organization_ids)
        elsif !columns.find { |c| c.name.eql?('organization_ids') }
          a_r_m.add_column(t_name, :organization_ids, :string)
        end
        a_r_m.change_column(t_name, :organization_ids, :string, limit: 2000, after: :publication_name)

        unless columns.find { |c| c.name.eql?('story_created') }
          a_r_m.add_column(t_name, :story_created, :boolean, default: false, after: :organization_ids)
        end
      end
    end

    def iter_id_column(t_name, iter_id)
      loki_story_creator do
        iter_column = a_r_m.columns(t_name).find { |c| c.name.eql?('iter_id') }

        if iter_column
          a_r_m.change_column_default(t_name, :iter_id, iter_id)
        else
          a_r_m.add_column(t_name, :iter_id, :integer, after: :id)
          a_r_m.change_column_default(t_name, :iter_id, iter_id)

          a_r_m.add_index(t_name, :iter_id, name: :iter)
        end
      end
    end

    def timestamps(t_name)
      loki_story_creator do
        a_r_m.add_column(t_name, :created_at, :datetime, null: true, after: :id) unless a_r_m.column_exists?(t_name, :created_at)
        a_r_m.add_column(t_name, :updated_at, :datetime, null: true, after: :created_at) unless a_r_m.column_exists?(t_name, :updated_at)
        a_r_m.add_column(t_name, :time_frame, :string,   null: true, after: :story_created) unless a_r_m.column_exists?(t_name, :time_frame)

        cr_at_query = created_at_default_value_query(t_name)
        a_r_b_conn.exec_query(cr_at_query)
        upd_at_query = updated_at_default_value_query(t_name)
        a_r_b_conn.exec_query(upd_at_query)
      end
    end
  end
end
