# frozen_string_literal: true

class ScrapeInstruction < ApplicationRecord
  belongs_to :scrape_task
end
