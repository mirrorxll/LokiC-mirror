# frozen_string_literal: true

class ClientsOpportunitiesJob < ApplicationJob
  queue_as :cron_tab

  def perform
    Client.all.each do |c|
      c.publications.each do |p|
        p.opportunities.each do |o|
          ClientOpportunity.find_or_create_by!(client: c, opportunity: o).touch
        end
      end
    end

    ClientOpportunity.where('DATE(updated_at) < CURRENT_DATE()').destroy_all
  end
end

