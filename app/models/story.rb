# frozen_string_literal: true

class Story < ApplicationRecord
  before_create { Table.story_set_as_created(staging_table.name, staging_row_id) }
  after_destroy { Table.story_set_as_not_created(staging_table.name, staging_row_id) }

  paginates_per 200

  scope :backdated_count, -> { where(backdated: true).count }
  scope :scheduled_count, -> { where(backdated: false).count }

  belongs_to :story_type
  belongs_to :iteration, class_name: 'StoryTypeIteration', foreign_key: :story_type_iteration_id
  belongs_to :export_configuration
  belongs_to :client
  belongs_to :publication
  belongs_to :output, dependent: :destroy
  belongs_to :time_frame

  has_many   :auto_feedback_confirmations, foreign_key: :sample_id, dependent: :destroy
  has_many   :fixes, class_name: 'SampleFix'

  def staging_table
    story_type.staging_table
  end

  def headline
    output.headline
  end

  def teaser
    output.teaser
  end

  def body
    output.body
  end

  def client_name
    publication.client.name
  end

  def publication_name
    publication.name
  end

  def pl_story_id
    public_send("pl_#{PL_TARGET}_story_id")
  end

  def link?
    pl_story_id.present?
  end

  def pl_link
    return unless link?

    target = Rails.env.production? ? 'pipeline' : 'pipeline-staging'
    "https://#{target}.locallabs.com/stories/#{pl_story_id}"
  end

  def live_link
    "#{publication.home_page}/stories/#{pl_story_id}"
  end

  def self.complete_scheduling?
    where(published_at: nil).limit(1).empty?
  end

  def self.ready_to_export
    where("pl_#{PL_TARGET}_story_id" => nil)
      .joins(:export_configuration, :publication, :output)
      .order(:published_at).where(backdated: false)
      .where.not(export_configurations: { tag: nil })
  end

  def self.not_exported
    where("pl_#{PL_TARGET}_story_id" => nil)
  end

  def self.exported
    where.not("pl_#{PL_TARGET}_story_id" => nil)
  end

  def self.exported_without_backdate
    where.not("pl_#{PL_TARGET}_story_id" => nil).where.not(backdated: true)
  end
end
