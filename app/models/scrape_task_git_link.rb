# frozen_string_literal: true

class ScrapeTaskGitLink < ApplicationRecord

  belongs_to :scrape_tasks, optional: true

  validates :link, format: { with: /(^https:\/\/github.com\/localitylabs\/HamsterProjects\/tree\/master\/projects\/)(.+)/,
                                    message: "no valid format" }, allow_nil: true, allow_blank: true

  before_save { link.strip! }
end
