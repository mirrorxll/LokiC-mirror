# frozen_string_literal: true

module ScrapeTasks
  class SchemasTablesJob < ScrapeTasksJob
    def perform(*_args)
      Host.find_each do |h|
        host_obj = Object.const_get(h.name)

        MiniLokiC::Connect::Mysql.on(host_obj).query('SHOW SCHEMAS;').to_a.each do |sc|
          Schema.find_or_create_by!(host: h, name: sc.values.first).touch
        end
      end

      Schema.where('DATE(updated_at) < CURRENT_DATE()').destroy_all
    end
  end
end
