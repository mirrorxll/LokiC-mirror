# frozen_string_literal: true

class DefaultProperty < ApplicationRecord # :nodoc:
  serialize :client_tag, Hash # client_id: tag_id or photobucket: photobucket_id

  belongs_to :data_set
  belongs_to :photo_bucket, optional: true
end
