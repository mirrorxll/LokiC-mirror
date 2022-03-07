# frozen_string_literal: true

module GoogleDriveClient
  class Base
    attr_accessor :session

    def initialize
      @session = GoogleDrive::Session.from_config('config/google_drive.json')
    end
  end
end
