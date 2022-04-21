
require_relative 'factoids/export_to_lp'

module Factoids
  include MiniLokiC::Connect

  def self.[]
    Factoids::ExportToLp.new
  end
end
