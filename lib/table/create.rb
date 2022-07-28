# frozen_string_literal: true

module Table
  module Create
    def create(t_name)
      t_name = schema_table(t_name)
      loki_story_creator { |conn| conn.create_table(t_name, options: 'DEFAULT CHARSET="utf8mb4" COLLATE="utf8mb4_unicode_520_ci"') }
      nil
    end

    def add_default_story_type_columns(t_name)
      t_name = schema_table(t_name)

      loki_story_creator do |conn|
        columns = conn.columns(t_name)

        unless columns.find { |c| c.name.eql?('client_id') }
          conn.add_column(t_name, :client_id, :integer, after: :iter_id)
        end

        unless columns.find { |c| c.name.eql?('client_name') }
          conn.add_column(t_name, :client_name, :string, after: :client_id)
        end

        unless columns.find { |c| c.name.eql?('publication_id') }
          conn.add_column(t_name, :publication_id, :integer, after: :client_name)
        end

        unless columns.find { |c| c.name.eql?('publication_name') }
          conn.add_column(t_name, :publication_name, :string, after: :publication_id)
        end

        unless columns.find { |c| c.name.eql?('time_frame') }
          conn.add_column(t_name, :time_frame, :string,   null: true, after: :publication_name)
        end

        if columns.find { |c| c.name.eql?('organization_id') }
          conn.rename_column(t_name, :organization_id, :organization_ids)
        elsif !columns.find { |c| c.name.eql?('organization_ids') }
          conn.add_column(t_name, :organization_ids, :string)
        end
        conn.change_column(t_name, :organization_ids, :string, limit: 2000, after: :publication_name)
      end
    end

    def add_default_factoid_type_columns(t_name)
      t_name = schema_table(t_name)

      loki_story_creator do |conn|
        columns = conn.columns(t_name)

        unless columns.find { |c| c.name.eql?('limpar_id') }
          conn.add_column(t_name, :limpar_id, :string, limit: 36, after: :iter_id)
        end

        unless columns.find { |c| c.name.eql?('limpar_year') }
          conn.add_column(t_name, :limpar_year, :integer, after: :limpar_id)
        end
      end
    end

    def delete_useless_columns(t_name)
      t_name = schema_table(t_name)

      loki_story_creator do |conn|
        columns = conn.columns(t_name)
        useless_columns = %w[source_table_id source_id
                             project_name debug exported_at county_prefix]

        useless_columns.each do |u_col|
          next unless columns.find { |c| c.name.eql?(u_col) }

          conn.remove_column(t_name, u_col)
        end
      end
    end

    def iter_id_column(t_name, iter_id)
      t_name = schema_table(t_name)

      loki_story_creator do |conn|
        iter_column = conn.columns(t_name).find { |c| c.name.eql?('iter_id') }

        if iter_column
          conn.change_column_default(t_name, :iter_id, iter_id)
        else
          conn.add_column(t_name, :iter_id, :integer, after: :id)
          conn.change_column_default(t_name, :iter_id, iter_id)

          conn.add_index(t_name, :iter_id, name: :iter)
        end
      end
    end

    def add_story_created(t_name)
      t_name = schema_table(t_name)

      loki_story_creator do |conn|
        unless conn.column_exists?(t_name, :story_created)
          conn.add_column(t_name, :story_created, :boolean, default: false, after: :organization_ids)
        end
      end
    end

    def add_article_created(t_name)
      t_name = schema_table(t_name)

      loki_story_creator do |conn|
        unless conn.column_exists?(t_name, :article_created)
          conn.add_column(t_name, :article_created, :boolean, default: false, after: :iter_id)
        end
      end
    end

    def timestamps(t_name)
      t_name = schema_table(t_name)

      loki_story_creator do |conn|
        unless conn.column_exists?(t_name, :created_at)
          conn.add_column(t_name, :created_at, :datetime, null: true, after: :id)
        end
        unless conn.column_exists?(t_name, :updated_at)
          conn.add_column(t_name, :updated_at, :datetime, null: true, after: :created_at)
        end

        cr_at_query = created_at_default_value_query(t_name)
        conn.exec_query(cr_at_query)
        upd_at_query = updated_at_default_value_query(t_name)
        conn.exec_query(upd_at_query)
      end
    end

    def rename_table(old_name, new_name)
      old_name = schema_table(old_name)
      new_name = schema_table(new_name)

      loki_story_creator { |conn| conn.rename_table(old_name, new_name) }
    end
  end
end
