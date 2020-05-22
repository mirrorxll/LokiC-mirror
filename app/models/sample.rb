# frozen_string_literal: true

class Sample < ApplicationRecord
  belongs_to :iteration
  belongs_to :export_configuration
  belongs_to :publication, optional: true
  belongs_to :output
end
