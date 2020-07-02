# frozen_string_literal: true

class DataSet < ApplicationRecord # :nodoc:
  belongs_to :account
  belongs_to :evaluator, optional: true, class_name: 'Account'
  belongs_to :src_release_frequency, optional: true, class_name: 'Frequency'
  belongs_to :src_scrape_frequency, optional: true, class_name: 'Frequency'

  has_many :story_types

  def evaluated?
    evaluated
  end
end
