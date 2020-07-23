ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do

    report_mm = Review.where(report_type: 'report_for_mm').first

    panel "Report MM (updated at #{report_mm.updated_at.strftime("%Y-%m-%d")})" do
      render 'admin/report_for_mm', sheets: JSON.parse(report_mm.table)
    end

    report_by_raw_source = Review.where(report_type: 'report_by_raw_source').first

    panel "Report by Raw Source (updated at #{report_by_raw_source.updated_at.strftime("%Y-%m-%d")})" do
      render 'admin/report_by_raw_source', sheets: JSON.parse(report_by_raw_source.table)
    end

  end # content

end
