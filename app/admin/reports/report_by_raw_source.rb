require_relative '../../../lib/pipeline_replica'

module Report
  module ReportByRawSource
    def self.report(*args)
      db05 = MiniLokiC::Connect::Mysql.on(DB05, 'loki_storycreator')

      publications = db05.query("select community_id from clients_communities_replica where client_name rlike 'MM - '").to_a.map { |r| r['community_id']}.join(',')

      stage_tables = db05.query("select stage_table from hyperlocal_stories_v2 where exported_at_prod >= '2019-07-01' group by stage_table").to_a.map { |r| r['stage_table']}

      hash_raw_sources = {}

      stage_tables.each do |stage_table|

        hash_raw_sources[stage_table.to_s] = db05.query("select raw.* from #{stage_table} st inner join raw_sources raw on st.source_table_id = raw.id limit 1").first
      rescue => e
        e.message
        next
      end

      sheets = []

      (1..12).each do |i|
        published_by_month = {}
        exported_by_month = {}

        hash_raw_sources.each do |key, value|
          p 'stage_table: ' + key
          begin
            data = db05.query("select count(if(month(cast(publish_on as date)) = #{i} and year(cast(publish_on as date)) = 2020, 1, null)) count_publish,
                                     count(if(month(cast(exported_at_prod as date)) = #{i} and year(cast(exported_at_prod as date)) = 2020, 1, null)) count_exported
                                  from #{key} s
            join hyperlocal_stories_v2 h on h.stage_table = '#{key}' and s.id = h.stage_id and pipeline_prod_id is not null and publication_id in (#{publications})")

            data.each do |row|
              if published_by_month[value.to_s]
                published_by_month[value.to_s] += row['count_publish']
              else
                published_by_month[value.to_s] = row['count_publish']
              end

              if exported_by_month[value.to_s]
                exported_by_month[value.to_s] += row['count_exported']
              else
                exported_by_month[value.to_s] = row['count_exported']
              end
            end
          rescue => e
            p e.message
            next
          end
        end
        sheets << {
          month: Date::MONTHNAMES[i],
          published: published_by_month,
          exported: exported_by_month
        }
      end
      report = Review.where(report_type: 'report_by_raw_source').first
      report.update_attribute(:table, sheets.to_json)
    end
  end
end