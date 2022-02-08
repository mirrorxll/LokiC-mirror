# frozen_string_literal: true

class TableLocation < ApplicationRecord
  belongs_to :table_location, polymorphic: true
end
