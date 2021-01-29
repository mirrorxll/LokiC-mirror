# frozen_string_literal: true

class CronTab < ApplicationRecord
  serialize :enabled, Hash

  belongs_to :story_type
end
