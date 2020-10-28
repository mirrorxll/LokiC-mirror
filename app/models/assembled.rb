# frozen_string_literal: true

class Assembled < SecondaryRecord # :nodoc
  belongs_to :week
  belongs_to :developer, optional: true, class_name: 'Account'

  def self.destroy_current(developer, week)
    where(developer: developer, week: week).destroy_all
  end
end
