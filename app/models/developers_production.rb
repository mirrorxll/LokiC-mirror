# frozen_string_literal: true

class DevelopersProduction < SecondaryRecord # :nodoc
  belongs_to :developer, optional: true, class_name: 'Account'
  belongs_to :iteration
end
