# frozen_string_literal: true

class Sample < ApplicationRecord
  belongs_to :iteration
  belongs_to :export_configuration
  belongs_to :publication, optional: true
  belongs_to :output, dependent: :delete
  belongs_to :time_frame, optional: true

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
    "https://pipeline.locallabs.com/stories/#{pl_production_id}"
  end

  def staging_link
    "https://pipeline-staging.locallabs.com/stories/#{pl_production_id}"
  end
end
