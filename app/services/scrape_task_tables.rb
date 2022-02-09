# frozen_string_literal: true

class ScrapeTaskTables
  def self.attach(scrape_task, params)
    new(scrape_task, params).send(:create)
  end

  private

  def initialize(scrape_task, params)
    @scrape_task = scrape_task
    @host = Host.find(params[:host_id])
    @schema = Schema.find(params[:schema_id])
    @table_names = params[:names]&.keep_if(&:present?) || []
  end

  def create
    @table_names.each_with_object([]) do |name, object|
      table = TableLocation.find_or_create_by(
        parent: (p @scrape_task),
        host: @host,
        schema: @schema,
        name: name
      )

      object << { table_id: table.id, table_name: table.name }
    end
  end
end
