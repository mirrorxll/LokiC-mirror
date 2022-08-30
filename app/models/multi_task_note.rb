# frozen_string_literal: true

class MultiTaskNote < ApplicationRecord # :nodoc:
  belongs_to :multi_task
  belongs_to :creator, class_name: 'Account'
end
