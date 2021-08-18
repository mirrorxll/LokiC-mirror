# frozen_string_literal: true

require 'svggraph'

require_relative 'mini_loki_c/error.rb'
require_relative 'graphs/svggraph_styles_patch.rb'
require_relative 'mini_loki_c/configuration.rb'
require_relative 'mini_loki_c/connect/mysql.rb'
require_relative 'mini_loki_c/extended_ruby_classes.rb'
require_relative 'mini_loki_c/formatize.rb'
require_relative 'mini_loki_c/population.rb'
require_relative 'mini_loki_c/creation.rb'
require_relative 'mini_loki_c/no_log.rb'
require_relative 'mini_loki_c/story_type_code.rb'
require_relative 'mini_loki_c/article_type_code.rb'
require_relative 'mini_loki_c/common.rb'
require_relative 'mini_loki_c/data_matching.rb'

# mini lokiC rails integration
module MiniLokiC
  extend Configuration
end
