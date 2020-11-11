# frozen_string_literal: true

class Sample < ApplicationRecord
  paginates_per 200

  belongs_to :iteration
  belongs_to :export_configuration
  belongs_to :client
  belongs_to :publication
  belongs_to :output, dependent: :destroy
  belongs_to :time_frame

  has_many   :auto_feedback_confirmations, dependent: :destroy
  has_many   :fixes, class_name: 'SampleFix'

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

  def link
    story_id = public_send("pl_#{PL_TARGET}_story_id")
    return unless story_id

    target = Rails.env.production? ? 'pipeline' : 'pipeline-staging'
    "https://#{target}.locallabs.com/stories/#{story_id}"
  end
end
