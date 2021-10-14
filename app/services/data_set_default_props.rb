# frozen_string_literal: true

class DataSetDefaultProps
  def self.setup!(data_set, params)
    new(data_set, params).send(:setup)
  end

  private

  def initialize(data_set, params)
    @data_set = data_set
    @photo_bucket = PhotoBucket.find_by(id: params[:photo_bucket_id])
    @cl_pub_tg_ids =
      params[:client_tag_ids].to_h.map { |_uid, row| row }.uniq { |row| [row[:client_id], row[:publication_id]] }
  end

  def setup
    @data_set.create_data_set_photo_bucket(photo_bucket: @photo_bucket) if @photo_bucket

    @cl_pub_tg_ids.each do |row|
      client = Client.find(row[:client_id])
      tag = Tag.find(row[:tag_id])
      publication = Publication.find_by(id: row[:publication_id])

      @data_set.client_publication_tags.create(client: client, publication: publication, tag: tag)
    end
  end
end
