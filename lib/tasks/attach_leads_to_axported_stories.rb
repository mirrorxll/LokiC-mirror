# frozen_string_literal: true

namespace :samples do
  desc 'create a new user'
  task attach_leads: :environment do
    pl = Pipeline[:production]

    Sample.where.not(pl_production_story_id: nil).find_each do |s|
      response = pl.get_story(s[:pl_production_story_id])
      lead_id = JSON.parse(response.body)['lead']['id']
      next if lead_id.nil?

      s.update(pl_production_lead_id: lead_id)
    end
  end
end
