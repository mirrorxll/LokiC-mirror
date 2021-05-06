class ImagesController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :find_parent_story_type
  skip_before_action :set_iteration

  before_action :file_name, only: %i[show destroy]

  def show
    if File.exist?(@file_name)
      send_data File.read(@file_name), disposition: 'attachment'
    else
      head 404
    end
  end

  def create
    view_file =
      if params[:file]
        FileUtils.mkdir_p(Rails.root.join('public/uploads/images'))

        ext = File.extname(params[:file].original_filename)
        file_name = "#{SecureRandom.urlsafe_base64}#{ext}"
        path = Rails.root.join('public/uploads/images/', file_name)

        File.open(path, 'wb') { |f| f.write(params[:file].read) }
        Rails.root.join('/images/', file_name).to_s
      end

    render json: { link: view_file }
  end

  def destroy
    status =
      if File.exist?(@file_name)
        File.delete(@file_name)
        200
      else
        404
      end

    head status
  end

  private

  def file_name
    @file_name = Rails.root.join('public', 'uploads', 'images', params[:name])
  end
end
