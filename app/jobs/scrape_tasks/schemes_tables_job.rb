# frozen_string_literal: true

module ScrapeTasks
  class SchemesTablesJob < ScrapeTasksJob
    def perform(*_args)
      Host.find_each do |host|
        host_obj = Object.const_get(host.name)

        MiniLokiC::Connect::Mysql.on(host_obj).query('show schemas;').to_a.each do |schema|
          Schema.find_or_create_by!(host: host, name: schema.values.first)
          puts schema.values.first
        end
      end
    end
  end
end
