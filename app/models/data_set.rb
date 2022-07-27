# frozen_string_literal: true

class DataSet < ApplicationRecord # :nodoc:
  before_create do
    self.status = Status.find_by(name: 'active')

    build_status_comment(subtype: 'status comment')
    build_general_comment(subtype: 'general comment')
  end

  belongs_to :account
  belongs_to :sheriff, class_name: 'Account', optional: true
  belongs_to :responsible_editor, class_name: 'Account', optional: true
  belongs_to :state, optional: true
  belongs_to :category, class_name: 'DataSetCategory', optional: true
  belongs_to :scrape_task, optional: true
  belongs_to :status, optional: true

  has_one :data_set_photo_bucket
  has_one :photo_bucket, through: :data_set_photo_bucket
  has_one :status_comment,  -> { where(subtype: 'status comment') }, as: :commentable, class_name: 'Comment'
  has_one :general_comment, -> { where(subtype: 'general comment') }, as: :commentable, class_name: 'Comment'

  has_many :story_types
  has_many :client_publication_tags, class_name: 'DataSetClientPublicationTag'
  has_many :clients, through: :client_publication_tags
  has_many :tags, through: :client_publication_tags
  has_many :change_history, as: :history
  has_many :alerts, as: :alert
  has_many :article_types
  has_many :table_locations, -> { includes(:host, :schema).order('hosts.name, schemas.name, table_locations.table_name') },
           as: :parent, dependent: :destroy

  has_and_belongs_to_many :scrape_tasks

  def updated_early?
    updated_at > created_at
  end
end
