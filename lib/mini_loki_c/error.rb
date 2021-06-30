# frozen_string_literal: true

module MiniLokiC
  class MiniLokiCError < StandardError; end

  class PopulationExecutionError < MiniLokiCError; end
  class CreationExecutionError < MiniLokiCError; end
  class CheckUpdatesExecutionError < MiniLokiCError; end
end
