# frozen_string_literal: true

class Sample < ApplicationRecord
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
    if PL_TARGET.eql?(:production)
      "https://pipeline.locallabs.com/stories/#{pl_production_story_id}"
    else
      "https://pipeline-staging.locallabs.com/stories/#{pl_staging_story_id}"
    end
  end
end
