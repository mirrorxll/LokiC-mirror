# frozen_string_literal: true

class Sample < ApplicationRecord
  belongs_to :iteration
  belongs_to :export_configuration
  belongs_to :publication, optional: true
  belongs_to :output, dependent: :delete
  belongs_to :time_frame, optional: true
end
