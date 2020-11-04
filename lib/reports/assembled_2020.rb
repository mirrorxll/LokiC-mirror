# frozen_string_literal: true

require 'rubyXL'
require 'rubyXL/convenience_methods'
require 'google_drive'

module Reports
  module Assembled2020
    def self.to_google_drive(assembleds)
      workbook = RubyXL::Workbook.new

      session = GoogleDrive::Session.from_config('config/google_drive.json')

      workbook[0].sheet_name = 'Assembled 2020'
      ['BLANK COLUMN','Date','Dept','Name','BLANK COLUMN','Updated Description',
       'Oppourtunity Name','Oppourtunity ID','Old Product Name',
       'SF Product ID','Client Name','Account Name',
       'Hours','BLANK COLUMN','BLANK COLUMN','Employment Classification'].each_with_index do |cell, j|
        workbook['Assembled 2020'].add_cell(0, j, cell)
        workbook['Assembled 2020'][0][j].change_font_bold(true)
      end

      [7,12,7,12,7,20,20,35,20,20,20,15,25,20,7,7,20].each_with_index do |width, k|
        workbook['Assembled 2020'].change_column_width(k, width)
      end

      # workbook['Assembled 2020'][0].change_text_wrap(true)

      assembleds.each_with_index do |row,j|
        workbook['Assembled 2020'].add_cell(j + 1, 1, (row.week.end + 1).strftime('%F'))
        workbook['Assembled 2020'].add_cell(j + 1, 2, row.dept)
        workbook['Assembled 2020'].add_cell(j + 1, 3, "#{row.developer.first_name} #{row.developer.last_name}")
        workbook['Assembled 2020'].add_cell(j + 1, 5, row.updated_description)
        workbook['Assembled 2020'].add_cell(j + 1, 6, row.oppourtunity_name)
        workbook['Assembled 2020'].add_cell(j + 1, 7, row.oppourtunity_id)
        workbook['Assembled 2020'].add_cell(j + 1, 8, row.old_product_name)
        workbook['Assembled 2020'].add_cell(j + 1, 9, row.sf_product_id)
        workbook['Assembled 2020'].add_cell(j + 1, 10, row.client_name)
        workbook['Assembled 2020'].add_cell(j + 1, 11, row.account_name)
        workbook['Assembled 2020'].add_cell(j + 1, 12, row.hours)
        workbook['Assembled 2020'].add_cell(j + 1, 15, row.developer.upwork ? 'Upwork' : 'International Contractor')
      end

      file = "Assembled 2020.xlsx"
      workbook.write(file)

      basename = File.basename(file, '.xlsx')

      session.upload_from_file(file, basename)
      api_file = GoogleDrive::File.new(session, session.file_by_title(basename))
      api_file.acl.push(type: 'anyone', role: 'writer')

      File.delete(file)

      LinkAssembled.create(week: assembleds.first.week, link: api_file.human_url)
    end
  end
end

