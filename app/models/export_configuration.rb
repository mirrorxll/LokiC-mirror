# frozen_string_literal: true

class ExportConfiguration < ApplicationRecord # :nodoc:
  belongs_to :story_type
  belongs_to :client, optional: true
  belongs_to :publication, optional: true
end
