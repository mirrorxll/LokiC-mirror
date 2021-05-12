# frozen_string_literal: true

class PostExportReport < ApplicationRecord
  belongs_to :iteration
  belongs_to :submitter, class_name: 'Account'
end
