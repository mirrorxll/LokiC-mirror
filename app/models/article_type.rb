# frozen_string_literal: true

class ArticleType < ApplicationRecord
  after_create do
    create_template
    create_fact_checking_doc

    iter = iterations.create!(name: 'Initial', current_account: current_account)
    update(current_iteration: iter)
  end

  before_update -> { tracking_changes(ArticleType) }

  validates_uniqueness_of :name, case_sensitive: true
  validates :source_link, :source_type, :source_name, :original_publish_date, presence: true, on: 'ArticleTypes::ExportsController#execute'

  belongs_to :data_set,          counter_cache: true
  belongs_to :editor,            class_name: 'Account'
  belongs_to :developer,         optional: true, class_name: 'Account'
  belongs_to :status,            optional: true
  belongs_to :current_iteration, optional: true, class_name: 'ArticleTypeIteration'
  belongs_to :kind,              optional: true
  belongs_to :topic,             optional: true

  has_one :staging_table, as: :staging_tableable
  has_one :template, as: :templateable
  has_one :fact_checking_doc, as: :fcdable

  has_one_attached :code

  has_many :iterations, class_name: 'ArticleTypeIteration'
  has_many :change_history, as: :history
  has_many :articles
  has_many :change_history, as: :history

  def id_name
    "##{id} #{name}"
  end

  def developer_fc_channel_name
    developer&.fact_checking_channel&.name
  end

  def iteration
    current_iteration
  end

  def download_code_from_db
    MiniLokiC::ArticleTypeCode[self].download
  end
end
