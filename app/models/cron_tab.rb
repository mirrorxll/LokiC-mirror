# frozen_string_literal: true

class CronTab < ApplicationRecord
  serialize :setup, Hash

  belongs_to :story_type

  def pattern
    "#{setup[:minute]} #{setup[:hour]} #{setup[:day]} #{setup[:minute]} #{setup[:minute]} "
  end
end
