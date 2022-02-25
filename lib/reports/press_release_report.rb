# frozen_string_literal: true

module Reports
  class PressReleaseReport
    attr_accessor :clients_counts
    attr_accessor :clients_names
    attr_accessor :max_week

    def initialize
      @clients_counts = PipelineReplica[:production].pl_replica.query(stories_query)
      @clients_names = @clients_counts.map { |row| row['client_name'] }.uniq
      @max_week = @clients_counts.max { |s| s['story_week'] }['story_week']
    end

    def data_for_grid_bar
      week_last = []
      week_before_last = []

      @clients_names.each do |client_name|
        data_last = @clients_counts.select { |c_count| c_count['client_name'] == client_name && c_count['story_week'] == @max_week }
        data_before_last = @clients_counts.select { |c_count| c_count['client_name'] == client_name && c_count['story_week'] == @max_week - 1 }
        week_last.push(data_last.blank? ? 0 : data_last.first['count_story_id'].to_i)
        week_before_last.push(data_before_last.blank? ? 0 : data_before_last.first['count_story_id'].to_i)
      end

      [{
         label: "story week #{@max_week - 1}",
         data: week_before_last,
         backgroundColor: [
           "rgba(255,165,0)"
         ],
         barThickness: 5
       },
       {
         label: "story week #{@max_week}",
         data: week_last,
         backgroundColor: [
           "rgba(50,150,200,0.3)"
         ],
         barThickness: 5
       }]
    end

    private

    def begin_date
      (Date.today - 7*6).beginning_of_week(:sunday).to_s
    end

    def stories_query
      <<~SQL
        select 'Manual' as prr_type, cc.id as client_id, cc.name as client_name, week(s.published_at) as story_week, count(s.id) as count_story_id
        from stories s
                 join data_entry_leads l on s.lead_id = l.id
                 join job_items j on l.job_item_id = j.id
                 join communities c on c.id = s.community_id
                 join client_companies cc on c.client_company_id = cc.id
        where
                j.content_type in ('press_release', 'press_release_repost') and
                date(s.published_at) >= date('2022-01-09') and (
                    cc.name like 'MM -%' or
                    cc.name in ('American Catholic','AIC - Newspapers','LGIS', 'Franklin Archer Trade Network', 'The Record') or
                    (cc.name = 'Metro Business Network' and c.name like '%Business Daily') or
                    (cc.name = 'Varsity Sports Network' and c.name = 'Prep Sports Wire')
                )
        group by cc.id, cc.name, week(s.published_at)
        
        UNION
        
        select 'HLE' as prr_type, cc.id as client_id, cc.name as client_name, week(s.published_at) as story_week, count(s.id) as count_story_id
        from stories s
                 join data_entry_leads l on s.lead_id = l.id
                 join job_items j on l.job_item_id = j.id
                 join communities c on c.id = s.community_id
                 join client_companies cc on c.client_company_id = cc.id
        where
            date(s.published_at) >= date('2022-01-09') and
            c.client_company_id = 224 and j.name like '%releases HLE%'
        group by cc.id, cc.name, week(s.published_at)
      SQL
    end
  end
end
