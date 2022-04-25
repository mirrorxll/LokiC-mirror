# frozen_string_literal: true

class ExportedStoryType < SecondaryRecord
  self.table_name = 'lokic_secondary_dev.exported_story_types'

  belongs_to :developer, class_name: 'Account'
  belongs_to :story_type
  belongs_to :iteration, class_name: 'StoryTypeIteration'
  belongs_to :week

  has_one :editor_post_export_report,  -> { where(report_type: 'editor') },
          dependent: :destroy, class_name: 'PostExportReport'
  has_one :manager_post_export_report, -> { where(report_type: 'manager') },
          dependent: :destroy, class_name: 'PostExportReport'

  scope :first_export, -> { where(first_export: true) }

  def self.begin_date(date)
    where('date_export >= ?', date)
  end
end
