# frozen_string_literal: true

module ScrapeTasks
  class SchemesTablesJob < ScrapeTasksJob
    def perform(*_args)
      Host.find_each do |host|
        host_obj = Object.const_get(host.name)

        MiniLokiC::Connect::Mysql.on(host_obj).query('show schemas;').to_a.each do |schema|
          Schema.find_or_create_by!(host: host, name: schema.values.first).touch
        end

      end

      Schema.where('DATE(updated_at) < CURRENT_DATE()').destroy_all
    end
  end
end
