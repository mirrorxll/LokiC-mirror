# frozen_string_literal: true

class ScrapeTask < ApplicationRecord
  before_create do
    self.status = Status.find_by(name: 'not started')
  end

  validates_presence_of   :name
  validates_uniqueness_of :name, case_sensitive: false
  validates :datasource_url, length: { maximum: 1000 }

  belongs_to :creator,   optional: true, class_name: 'Account'
  belongs_to :scraper,   optional: true, class_name: 'Account'
  belongs_to :frequency, optional: true
  belongs_to :status,    optional: true

  has_one :notes_on_datasource,   as: :text, class_name: 'Text'
  has_one :notes_on_scrapability, as: :text, class_name: 'Text'
  has_one :notes_on_status,       as: :text, class_name: 'Text'
  has_one :instruction,           as: :text, class_name: 'Text'
  has_one :evaluation_doc,        as: :text, class_name: 'Text'
end
