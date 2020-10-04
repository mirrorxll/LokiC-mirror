# frozen_string_literal: true

class Sample < ApplicationRecord
  belongs_to :iteration
  belongs_to :export_configuration
  belongs_to :client, optional: true
  belongs_to :publication, optional: true
  belongs_to :output, dependent: :destroy
  belongs_to :time_frame, optional: true

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

  def production_link
    if ENV['RAILS_ENV'].eql?('production')
      "https://pipeline.locallabs.com/stories/#{pl_production_id}"
    else
      "https://pipeline-staging.locallabs.com/stories/#{pl_staging_id}"
    end
  end
end
