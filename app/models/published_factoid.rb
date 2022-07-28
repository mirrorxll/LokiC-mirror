# frozen_string_literal: true

class PublishedFactoid < ApplicationRecord
  belongs_to :developer, class_name: 'Account'
  belongs_to :factoid_type
  belongs_to :iteration, class_name: 'FactoidTypeIteration'
end
