# frozen_string_literal: true

class DataSetDefaultProps
  def self.setup(data_set, params)
    new(data_set, params).send(:stp)
  end

  private

  def initialize(data_set, params)
    @data_set = data_set
    @photo_bucket = PhotoBucket.find_by(id: params[:photo_bucket_id])
    @client_tag_ids = params[:client_tag_ids]
  end

  def stp
    @data_set.create_data_set_photo_bucket(photo_bucket: @photo_bucket) if @photo_bucket

    @client_tag_ids.each do |_uid, row|
      client = Client.find(row[:client_id])
      tag = Tag.find(row[:tag_id])

      @data_set.client_tags.create(client: client, tag: tag)
    end
  end
end
