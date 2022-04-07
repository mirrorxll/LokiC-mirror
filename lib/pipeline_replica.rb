# frozen_string_literal: true

# Make sql-requests to PL staging/production replica
module PipelineReplica
  include MiniLokiC::Connect

  def self.[](environment)
    PipelineReplica::Client.new(environment.to_sym)
  end
end
