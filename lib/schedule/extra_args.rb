# frozen_string_literal: true

module Schedule
  module ExtraArgs # :nodoc:
    def self.stage_ids(staging_table, arg)
      # client = MiniLokiC::Connect::Mysql.on(DB05, 'loki_storycreator')
      client = ActiveRecord::Base.connection
      query = "SELECT id FROM #{staging_table} WHERE #{arg};"
      client.exec_query(query).to_a.map { |x| x['id'] }
    end
  end
end