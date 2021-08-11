# frozen_string_literal: true

class ProductionRemoval < ApplicationRecord
  belongs_to :iteration, class_name: 'StoryTypeIteration'
  belongs_to :account
end
