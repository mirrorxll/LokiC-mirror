# frozen_string_literal: true

class ExportedStoryType < SecondaryRecord
  belongs_to :developer, class_name: 'Account'
  belongs_to :story_type
  belongs_to :iteration
  belongs_to :week

  has_one :editor_post_export_report,  -> { where(report_type: 'editor') },
          dependent: :destroy, class_name: 'PostExportReport'
  has_one :manager_post_export_report, -> { where(report_type: 'manager') },
          dependent: :destroy, class_name: 'PostExportReport'

  def self.begin_date(date)
    where('date_export >= ?', date)
  end
end
