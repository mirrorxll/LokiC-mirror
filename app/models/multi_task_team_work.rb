# frozen_string_literal: true

class MultiTaskTeamWork < ApplicationRecord # :nodoc:
  belongs_to :multi_task
  belongs_to :creator, class_name: 'Account'

  def self.done
    joins(:multi_task).where('status_id=?', Status.find_by(name: 'done'))
  end
end
