# frozen_string_literal: true

class ScrapeTaskTables
  def self.attach!(params)
    new(params).send(:create!)
  end

  private

  def initialize(params)
    @host = Hoparams[:host]
  end
end