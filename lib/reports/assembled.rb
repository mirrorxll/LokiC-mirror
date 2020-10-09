# frozen_string_literal: true

module Reports
  module Assembled
    def self.to_google_drive
      workbook = RubyXL::Workbook.new
      session = GoogleDrive::Session.from_config('config/google_drive.json')

      assembleds = Assembled.all

      assembleds.each_with_index do |table, i|
        workbook[0].sheet_name = 'Assembled 2020'
        ['Date','Dept','Name','Updated Description',
         'Oppourtunity Name','Oppourtunity ID','Old Product Name',
         'SF Product ID','Client Name','Account Name',
         'Hours', 'Employment Classification'].each_with_index do |cell, j|
          workbook[0].add_cell(0, j, cell)
          workbook[0][0][j].change_font_bold(true)
        end

        [10,10,10,20,20,20,20,20,20,20,10,20, 20, 20].each_with_index do |width, k|
          workbook["#{table[:month]}"].change_column_width(k, width)
        end

        table.each_with_index do |row,j|
          workbook[0].add_cell(j + 1, 0, row.date)
          workbook[0].add_cell(j + 1, 1, row.dept)
          workbook[0].add_cell(j + 1, 2, row.name)
          workbook[0].add_cell(j + 1, 3, row.updated_description)
          workbook[0].add_cell(j + 1, 4, row.oppourtunity_name)
          workbook[0].add_cell(j + 1, 5, row.oppourtunity_id)
          workbook[0].add_cell(j + 1, 6, row.old_product_name)
          workbook[0].add_cell(j + 1, 7, row.sf_product_id)
          workbook[0].add_cell(j + 1, 8, row.client_name)
          workbook[0].add_cell(j + 1, 9, row.account_name)
          workbook[0].add_cell(j + 1, 10, row.hours)
          workbook[0].add_cell(j + 1, 11, row.employment_classification)
        end
      end

      file = "Assembled 2020.xlsx"
      workbook.write(file)

      basename = File.basename(file, '.xlsx')

      session.upload_from_file(file, basename)
      api_file = GoogleDrive::File.new(session, session.file_by_title(basename))
      api_file.acl.push(type: 'anyone', role: 'writer')

      File.delete(file)

      puts "#{basename}: #{api_file.human_url}"
      "#{basename}: #{api_file.human_url}"
    end
  end
end
