# frozen_string_literal: true

require_relative 'mini_loki_c/connect/pgsql.rb'
require_relative 'limpar_replica/client.rb'

module LimparReplica
  include MiniLokiC::Connect

  def self.[](environment)
    LimparReplica::Client.new(environment.to_sym)
  end
end
