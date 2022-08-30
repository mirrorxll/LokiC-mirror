# frozen_string_literal: true

class SchemasTablesTask
  def perform(host = nil)
    host ? update(host) : Host.find_each { |h| update(h) }
  end

  private

  def update(host)
    begin
      conn = MiniLokiC::Connect::Mysql.on(Object.const_get(host.name))
    rescue StandardError
      return
    end

    conn.query('SHOW SCHEMAS;').to_a.each do |schema_row|
      schema = Schema.find_or_create_by!(host: host, name: schema_row.values.first)

      conn.query("SHOW TABLES FROM `#{schema.name}`;").to_a.map do |table_row|
        table = SqlTable.find_or_create_by!(schema: schema, name: table_row.values.first)
        table.touch
        table.update(presence: true)
      end

      schema.sql_tables.reload.where('DATE(updated_at) < CURRENT_DATE()').update_all(presence: false)
      schema.touch
      schema.update(presence: true)
    end

    host.schemas.reload.where('DATE(updated_at) < CURRENT_DATE()').update_all(presence: false)

    conn.close
  end
end
