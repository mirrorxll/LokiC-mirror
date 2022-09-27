# frozen_string_literal: true

class ScrapeTaskGitLink < ApplicationRecord
  belongs_to :scrape_tasks, optional: true

  validates :link, format: { with: /(^https:\/\/github.com\/localitylabs\/HamsterProjects\/tree\/master\/projects\/)(.+)/,
                                    message: "valid format https://github.com/localitylabs/HamsterProjects/tree/master/projects/....." }, allow_nil: true, allow_blank: true

end
