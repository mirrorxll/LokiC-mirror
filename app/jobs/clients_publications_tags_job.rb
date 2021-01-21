class ClientsPublicationsTagsJob < ApplicationJob
  queue_as :default

  def perform
    Process.wait(
      fork do
        clients_pubs_tags = PipelineReplica[:production].get_clients_publications_tags
        clients_pubs_tags.reject! { |row| row['client_name'].eql?('Metric Media') }

        clients_pubs_tags.flatten.each do |cl_pub_tags|
          client = update_client(cl_pub_tags)
          publication = update_publication(client, cl_pub_tags)
          update_tags(publication, cl_pub_tags)
        end

        mm_gen = Client.find_or_initialize_by(name: 'Metric Media')
        mm_gen.author = Author.find_by(name: 'Metric Media News Service')
        mm_gen.save!
        mm_gen.touch

        Client.where('DATE(updated_at) < CURRENT_DATE()').delete_all
        Publication.where('DATE(updated_at) < CURRENT_DATE()').delete_all
      end
    )
  end

  private

  def author(client_name)
    author =
      if client_name.eql?('The Record')
        'Record Inc News Service'
      else
        'Metric Media News Service'
      end

    Author.find_or_create_by!(name: author)
  end

  def update_client(cl_pub_tags)
    client = Client.find_or_initialize_by(pl_identifier: cl_pub_tags['client_id'])
    client_name = cl_pub_tags['client_name']
    client.author = author(client_name)
    client.name = client_name
    client.save!
    client.touch

    client
  end

  def update_publication(client, cl_pub_tags)
    pub = client.publications.find_or_initialize_by(pl_identifier: cl_pub_tags['publication_id'])
    pub.name = cl_pub_tags['publication_name']
    pub.home_page = drop_ends_slash(cl_pub_tags['site_url'])
    pub.save!
    pub.touch

    pub
  end

  def drop_ends_slash(url)
    return if url.blank?

    url.end_with?('/') ? url[0...-1] : url
  end

  def update_tags(publication, cl_pub_tags)
    return if cl_pub_tags['tags'].nil?

    tags = cl_pub_tags['tags'].split(':::').map { |tag| [tag.split('::')].to_h }
    tags.reduce(:merge).each do |id, name|
      tag = Tag.find_or_initialize_by(pl_identifier: id)
      tag.name = name
      tag.save!

      next if publication.tags.exists?(tag.id)

      publication.tags << tag
    end
  end
end
