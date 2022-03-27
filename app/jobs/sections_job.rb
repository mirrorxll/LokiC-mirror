# frozen_string_literal: true

class SectionsJob < ApplicationJob
  queue_as :lokic

  def perform
    PipelineReplica[:production].get_sections.each do |raw_section|
      section = Section.find_or_initialize_by(pl_identifier: raw_section['id'])
      section.name = raw_section['name']
      section.save!
      section.touch

      clients_section(section)
    end

    Section.where('DATE(updated_at) < DATE(created_at)').delete_all
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
