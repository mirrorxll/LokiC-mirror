# frozen_string_literal: true

class SectionsJob < ApplicationJob
  queue_as :default

  def perform
    Process.wait(
      fork do
        PipelineReplica[:production].get_sections.each do |raw_section|
          section = Section.find_or_initialize_by(pl_identifier: raw_section['id'])
          section.name = raw_section['name']
          section.save!

          clients_section(section)
        end
      end
    )
  end

  private

  def clients_section(section)
    return unless [2, 16].include?(section.pl_identifier)

    where =
      if section.pl_identifier.eql?(2)
        "name = 'LGIS' OR (name != 'The Record' AND name NOT LIKE 'MM - %')"
      elsif section.pl_identifier.eql?(16)
        "name = 'LGIS' OR name = 'The Record' OR name LIKE 'MM - %'"
      end

    Client.where(where).each do |client|
      client.sections << section unless client.sections.exists?(section.id)
    end
  end
end
