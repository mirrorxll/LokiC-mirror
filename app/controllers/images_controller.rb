class ImagesController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :find_parent_story_type
  skip_before_action :find_parent_article_type
  skip_before_action :set_story_type_iteration
  skip_before_action :set_article_type_iteration

  before_action :file_name, only: :download

  def upload
    FileUtils.mkdir_p(Rails.root.join('public/uploads/images'))

    ext = File.extname(params[:file].original_filename)
    file_name = "#{SecureRandom.urlsafe_base64}#{ext}"
    path = Rails.root.join('public/uploads/images/', file_name)

    File.open(path, 'wb') { |f| f.write(params[:file].read) }

    render json: { link: "/images/download?name=#{file_name}" }
  end

  def download
    if File.exist?(@file_name)
      send_data File.read(@file_name), disposition: 'attachment'
    else
      head 404
    end
  end

  private

  def file_name
    @file_name = Rails.root.join('public', 'uploads', 'images', params[:name])
  end
end
