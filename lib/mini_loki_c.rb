# frozen_string_literal: true

require_relative 'mini_loki_c/configuration.rb'
require_relative 'mini_loki_c/connect/mysql.rb'
require_relative 'mini_loki_c/code.rb'

# mini lokiC rails integration
module MiniLokiC
  extend Configuration
end
