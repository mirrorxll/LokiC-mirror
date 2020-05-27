# frozen_string_literal: true

module Schedule
  module ExtraArgs # :nodoc:
    def self.get_stage_ids(staging_table, arg)
      client = MiniLokiC::Connect::Mysql.on(DB05, 'loki_storycreator')
      query = "select id from #{staging_table} where #{arg}"
      stage_ids = client.query(query).to_a.map{|x| x['id']}
      client.close
      stage_ids
    end
  end
end