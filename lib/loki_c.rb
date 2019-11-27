# frozen_string_literal: true

module LokiC # :nodoc:
  autoload :Story, 'loki_c/story.rb'
  autoload :Queries, 'loki_c/queries.rb'
  autoload :Connection, 'loki_c/connect.rb'
  autoload :Mysql, 'loki_c/connect/mysql.rb'
end
