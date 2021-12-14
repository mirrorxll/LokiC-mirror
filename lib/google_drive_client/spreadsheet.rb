# frozen_string_literal: true

# uncomment if you need more functionality
# require 'rubyXL/convenience_methods/cell'
# require 'rubyXL/convenience_methods/color'
# require 'rubyXL/convenience_methods/font'
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'

module GoogleDriveClient
  class Spreadsheet < GoogleDriveClient::Base
    attr_accessor :filepath

    def initialize(name:)
      super()
      @filepath = "public/spreadsheets/#{name}.xlsx"
      @filename = "#{name}.xlsx"
      @file_basename = name
      @workbook =
        if File.exist?(@filepath)
          RubyXL::Parser.parse(@filepath)
        else
          RubyXL::Workbook.new.write(@filepath)
        end
    end

    def upload(access_options = { type: 'anyone', role: 'writer' })
      @session.upload_from_file(@filepath, @file_basename)

      file = @session.file_by_title(@file_basename)
      uploaded_file = GoogleDrive::File.new(@session, file)
      uploaded_file.acl.push(access_options)
      uploaded_file.human_url
    end

    def download
      @session
        .file_by_title(@file_basename)
        .export_as_file(@filepath)
      @filepath
    end
  end
end
