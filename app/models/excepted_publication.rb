# frozen_string_literal: true

class ExceptedPublication < ApplicationRecord
  belongs_to :story_type
  belongs_to :client
  belongs_to :publication
end
