# frozen_string_literal: true

module FactoidTypes::ShowHelper
  def factoid_types_blocked_item?
    true unless [
      @factoid_type.staging_table_attached.eql?(false),
      @factoid_type.staging_table&.indices_modifying.eql?(true),
      @factoid_type.staging_table&.columns_modifying.eql?(true),
      @iteration.population.eql?(false),
      @iteration.purge_population.eql?(false),
      @iteration.samples.eql?(false),
      @iteration.purge_samples.eql?(false),
      @iteration.creation.eql?(false),
      @iteration.purge_creation.eql?(true),
      @iteration.export.eql?(false),
      @iteration.purge_export.eql?(true)
    ].any?
  end
end
