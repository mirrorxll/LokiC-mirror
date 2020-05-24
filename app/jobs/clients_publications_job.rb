class ClientsPublicationsJob < ApplicationJob
  queue_as :default

  def perform
    clients_pubs = PipelineReplica[:production].get_clients_publications
    clients_pubs = clients_pubs.group_by { |cl_pub| cl_pub['client_id'] }

    clients_pubs.each do |real_cl_id, cl_pubs|
      client = update_client(real_cl_id, cl_pubs.first)

      cl_pubs.each { |pub| update_publication(client.publications, pub) }
    end
  end

  private

  def author(pub)
    author =
      if pub['client_name'].eql?('The Record')
        'Record Inc News Service'
      else
        'Metric Media News Service'
      end

    Author.find_or_initialize_by(name: author)
  end

  def update_client(real_client_id, cl_pub)
    client = Client.find_or_initialize_by(pl_identifier: real_client_id)
    client.author = author(cl_pub)
    client.name = cl_pub['client_name']
    client.save!

    client
  end

  def update_publication(relation, pub)
    p = relation.find_or_initialize_by(pl_identifier: pub['publication_id'])
    p.pl_identifier = pub['publication_id']
    p.name = pub['publication_name']
    p.save!
  end
end
