# frozen_string_literal: true

class Assembled < SecondaryRecord # :nodoc
  belongs_to :week
  belongs_to :developer, optional: true, class_name: 'Account'
end
