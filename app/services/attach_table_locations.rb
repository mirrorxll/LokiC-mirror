# frozen_string_literal: true

class AttachTableLocations
  def self.to(model, params)
    new(model, params).send(:attach)
  end

  private

  def initialize(model, params)
    @model = model
    @host = Host.find(params[:host_id])
    @schema = Schema.find(params[:schema_id])
    @table_names = params[:names]&.keep_if(&:present?) || []
  end

  def attach
    @table_names.each_with_object([]) do |name, object|
      table = TableLocation.find_or_initialize_by(
        parent: @model, host: @host,
        schema: @schema, table_name: name
      )
      next if table.persisted?

      table.save!

      object << { id: table.id, location: table.full_name }
    end
  end
end
