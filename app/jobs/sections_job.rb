# frozen_string_literal: true

class SectionsJob < ApplicationJob
  queue_as :lokic

  def perform
    Process.wait(
      fork do
        PipelineReplica[:production].get_sections.each do |raw_section|
          section = Section.find_or_initialize_by(pl_identifier: raw_section['id'])
          section.name = raw_section['name']
          section.save!
          section.touch

          clients_section(section)
        end

        Section.where('DATE(updated_at) < CURRENT_DATE()').delete_all
      end
    )
  end

  private

  def clients_section(section)
    return unless [2, 16].include?(section.pl_identifier)

    where = section.pl_identifier.eql?(2) ? "name = 'LGIS'" : '1 = 1'

    Client.where(where).each do |client|
      client.sections << section unless client.sections.exists?(section.id)
    end
  end
end
