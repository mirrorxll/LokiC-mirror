# frozen_string_literal: true

module Table
  module Destroy
    def drop(t_name)
      loki_story_creator { a_r_m.drop_table(t_name) }
    end
  end
end
