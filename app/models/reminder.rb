# frozen_string_literal: true

class Reminder < ApplicationRecord
  belongs_to :story_type
end
