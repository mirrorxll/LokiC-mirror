# frozen_string_literal: true

class Sample < ApplicationRecord
  belongs_to :output
  belongs_to :publication, optional: true
end
