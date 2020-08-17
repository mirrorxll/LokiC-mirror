# frozen_string_literal: true

class SecondaryRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :secondary }
end
