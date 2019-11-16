# frozen_string_literal: true

class SummernoteUploadsController < ApplicationController # :nodoc:
  def create
    @upload = SummernoteUpload.new(upload_params)
    @upload.save

    respond_to do |format|
      format.json do
        render json: { url: rails_blob_url(@upload.image), upload_id: @upload.id }
      end
    end
  end

  def destroy
    @upload = SummernoteUpload.find(params[:id])
    @upload.destroy

    respond_to do |format|
      format.json { render json: { status: :ok } }
    end
  end

  private

  def upload_params
    params.require(:upload).permit(:image)
  end
end
