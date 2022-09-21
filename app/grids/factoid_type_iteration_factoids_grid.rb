# frozen_string_literal: true

class FactoidTypeIterationFactoidsGrid
  include Datagrid

  scope do
    Factoid.includes(:output)
  end

  filter(:output, :string, header: 'Body', left: true) do |value, scope|
    outputs = FactoidOutput.where('body LIKE ?', '%' + value + '%')
    scope.where(id: outputs.ids)
  end
  filter(:limpar_factoid_id, :string, header: 'Limpar ids', multiple: ',', left: true) do |value, scope|
    scope.where(limpar_factoid_id: value.map(&:strip))
  end

  filter(:exported_at, :datetime, range: true, type: 'date')

  column(:factoid, header: 'Factoid', mandatory: true) do |rec|
    rec.output.body
  end
  column(:lp_link, header: "Limpar", mandatory: true) do |model|
    link = model.link? ? "http://limpar.locallabs.com/editorial_factoids/#{model.limpar_factoid_id}" : '---'
    format(link) do
      model.link? ? link_to('limpar', model.lp_link, target:'_blank') : '---'
    end
  end
  column(:lokic_link, header: "LokiC", mandatory: true) do |model|
    link = "https://lokic.locallabs.com/factoid_types/#{model.factoid_type.id}/iterations/#{model.iteration.id}/factoids/#{model.id}"
    format(link) do
      link_to('lokic', factoid_type_iteration_sample_path(@factoid_type, @iteration, model), target:'_blank')
    end
  end
  column(:exported_at, mandatory: true)
end
