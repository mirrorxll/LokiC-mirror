require_relative '../../../lib/pipeline_replica'

module Report
  module ReportForMM
    def self.report
      db05 = MiniLokiC::Connect::Mysql.on(DB05, 'loki_storycreator')

      pl_replica = MiniLokiC::Connect::Mysql.on(PL_PROD_DB_HOST, 'jnswire_prod', MiniLokiC.mysql_pl_replica_user, MiniLokiC.mysql_pl_replica_password)

      publications = db05.query("select community_id from clients_communities_replica where client_name rlike 'MM - '").to_a.map { |r| r['community_id']}.join(',')

      sheets = {}

      (Date.today-6..Date.today).reverse_each do |date|
        date = date.strftime("%Y-%m-%d")
        table = []
        (1..12).each do |i|
          data_per_month = pl_replica.query("select count(if(month(s.created_at) = #{i} and year(s.created_at) = 2020, 1, null)) total_exported,
                                              count(if(month(s.published_at) = #{i} and year(s.published_at) = 2020, 1,null)) published
                                  from stories s
                                         join data_entry_leads l on s.lead_id = l.id
                                         join job_items j on l.job_item_id = j.id and j.content_type = 'hle'
                                  where date(s.created_at) >= '2019-07-01' and date(s.created_at) <= '#{date}' and community_id in (#{publications})").first
          table << {
            month: Date::MONTHNAMES[i],
            total_exported: data_per_month['total_exported'].to_s,
            total_published: data_per_month['published'].to_s
          }
        end
        sheets[date] = table
      end
      report = Review.where(report_type: 'report_for_mm').first
      report.update_attribute(:table, sheets.to_json)
    end
  end
end

