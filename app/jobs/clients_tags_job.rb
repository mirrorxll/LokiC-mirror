# frozen_string_literal: true

class ClientsTagsJob < ApplicationJob
  queue_as :lokic

  def perform
    Process.wait(
      fork do
        Client.all.each { |cl| attach_tags_to(cl) }

        mm_generic = Client.find_by(name: 'Metric Media')
        mm_by_state = Client.where('name LIKE :query', query: 'MM -%').to_a
        attach_tags_to_mm_generic(mm_generic, mm_by_state)
      end
    )
  end

  private

  def attach_tags_to(client)
    tags = client.publications.to_a.map { |pub| pub.tags.to_a }
    puts tags.count
    tags.flatten.uniq.each { |t| client.tags << t unless client.tags.exists?(t.id) }
  end

  def attach_tags_to_mm_generic(mm_generic, mm_by_state)
    mm_by_state.each do |cl|
      cl.tags.each { |t| mm_generic.tags << t unless mm_generic.tags.exists?(t.id) }
    end
  end
end
