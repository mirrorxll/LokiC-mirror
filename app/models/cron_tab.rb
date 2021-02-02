# frozen_string_literal: true

class CronTab < ApplicationRecord
  serialize :setup, Hash

  belongs_to :story_type
end
