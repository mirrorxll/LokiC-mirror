
# frozen_string_literal: true

namespace :table_location do
  desc 'Checks if table presence in the DB'
  task check_presence: :environment do
    hosts = TableLocation.select(:host_id).distinct
    hosts.each do |host|
      current_host    = Host.find(host.host_id)
      table_locations = TableLocation.where(host_id: current_host.id)
      schemas         = table_locations.select(:schema_id).distinct
      schemas.each do |schema|
        current_schema = Schema.find(schema.schema_id)
        current_tables = table_locations.where(schema_id: current_schema.id)
        conn           = MiniLokiC::Connect::Mysql.on(Object.const_get(current_host.name), current_schema.name)
        current_tables.each do |table|
          table_name = table['table_name'] || table.table_name
          q = <<~SQL
            SELECT *
            FROM information_schema.tables
            WHERE table_schema = '#{current_schema.name}'
              AND table_type = 'BASE TABLE'
              AND table_name = '#{table_name}'
            LIMIT 1;
          SQL
          presence = conn.query(q).to_a

          table.update!(presence: presence.size.zero? ? false : true)
        end
        conn.close
      end
    end
  end
end