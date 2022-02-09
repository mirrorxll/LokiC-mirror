# frozen_string_literal: true

class DataSetLocation < ApplicationRecord
  belongs_to :data_set_location, polymorphic: true
  belongs_to :host
  belongs_to :schema
end
