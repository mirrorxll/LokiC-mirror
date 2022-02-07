# frozen_string_literal: true

class DataSetLocation < ApplicationRecord
  belongs_to :data_set_location, polymorphic: true
end
