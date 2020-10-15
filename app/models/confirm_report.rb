# frozen_string_literal: true

class ConfirmReport < SecondaryRecord # :nodoc
  belongs_to :developer, optional: true, class_name: 'Account'
  belongs_to :week
end
