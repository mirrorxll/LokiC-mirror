# frozen_string_literal: true

class ScrapeTaskTag < ApplicationRecord
  has_and_belongs_to_many :scrape_tasks
end
