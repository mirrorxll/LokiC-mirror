# frozen_string_literal: true

class StoryType < ApplicationRecord # :nodoc:
  belongs_to :editor,            class_name: 'Account'
  belongs_to :developer,         optional: true, class_name: 'Account'
  belongs_to :data_set,          counter_cache: true
  belongs_to :frequency,         optional: true
  belongs_to :photo_bucket,      optional: true
  belongs_to :current_iteration, optional: true, class_name: 'Iteration'

  has_one :staging_table
  has_one :template
  has_one :fact_checking_doc
  has_one :cron_tab

  has_many :iterations
  has_many :export_configurations
  has_many :configurations_no_tags, -> { where(tag: nil).or(where(skipped: true)) }, class_name: 'ExportConfiguration'
  has_many :samples

  has_many :clients_publications_tags, class_name: 'StoryTypeClientPublicationTag'
  has_many :clients, through: :clients_publications_tags
  has_many :tags, through: :clients_publications_tags
  has_many :publications, through: :clients_publications_tags

  has_one_attached :code

  validates :name, uniqueness: true

  before_create do
    build_template
    build_fact_checking_doc
    iterations.build(name: 'Initial')
  end

  after_create { update(current_iteration: iterations.first) }

  def number_name
    "##{id} #{name}"
  end

  def developer_slack_id
    developer&.slack&.identifier
  end

  def iteration
    current_iteration
  end

  def download_code_from_db
    MiniLokiC::Code.download(iteration)
  end

  def client_pl_ids
    clients_publications_tags.flat_map do |cl_t|
      if cl_t.client.name.eql?('Metric Media')
        Client.where('name LIKE :like', like: 'MM -%').map(&:pl_identifier)
      else
        cl_t.client.pl_identifier
      end
    end
  end
end
