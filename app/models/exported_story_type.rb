# frozen_string_literal: true

class ExportedStoryType < SecondaryRecord # :nodoc
  belongs_to :developer, optional: true, class_name: 'Account'
  belongs_to :iteration

  def self.developer(id)
    where(developer_id: id)
  end

  def self.begin_date(date)
    where("date_export > ?", date)
  end
end
