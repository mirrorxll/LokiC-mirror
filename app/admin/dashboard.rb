ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    div class: "blank_slate_container", id: "dashboard_default_message" do
      span class: "blank_slate" do
        span I18n.t("active_admin.dashboard_welcome.welcome")
        small I18n.t("active_admin.dashboard_welcome.call_to_action")
      end
    end

    report_mm = Review.where(report_type: 'report_for_mm').first

    panel "Report MM (updated at #{report_mm.updated_at.strftime("%Y-%m-%d")})" do
      render 'admin/report_for_mm', sheets: JSON.parse(report_mm.table)
    end

    report_by_raw_source = Review.where(report_type: 'report_by_raw_source').first

    panel "Report by Raw Source (updated at #{report_by_raw_source.updated_at.strftime("%Y-%m-%d")})" do
      render 'admin/report_by_raw_source', sheets: JSON.parse(report_by_raw_source.table)
    end

    # render 'admin/report_for_mm', sheets: Report::ReportForMM.report

    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  end # content

end
