# frozen_string_literal: true

class PostExportReport < SecondaryRecord
  belongs_to :exported_story_type
  belongs_to :submitter, class_name: 'Account'

  def self.all_editor_reports
    where(report_type: 'editor')
  end

  def self.all_manager_reports
    where(report_type: 'manager')
  end
end
