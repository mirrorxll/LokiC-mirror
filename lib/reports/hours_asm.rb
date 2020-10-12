# frozen_string_literal: true

module Reports
  module HoursAsm
    def self.to_clip_b(txt)
      `echo '#{txt.to_s}' | xclip -selection clipboard`
    end

    def self.tsv_to_hash(tsv, headers)
      entries = tsv.split("\n")
      entries.map! {|row| row = row.split("\t") }
      entries.map! do |row|
        new_row = {}
        row.each_with_index do |col, col_i|
          header = headers[col_i]
          new_row[header] = col
        end
        new_row
      end
      entries
    end

    def self.hash_to_tsv(hash, headers)
      tsv = ""
      headers.each do |head|
        tsv += "#{hash[head]}\t"
      end
      tsv
    end

    def self.q(dev_week)
      # headers = ["Name", "Hours", "Updated Description", "Client Name", "(SKIP COLUMN)", "Date", "(SKIP COLUMN)", "(SKIP COLUMN)", "Employment Classification", "Description"]
      # dev_week = tsv_to_hash(tsv, headers)
      date = Date.today - (Date.today.wday - 1)
      puts '/////'
      puts dev_week
      puts dev_week.first
      puts dev_week.first.developer

      puts '////'
      puts dev_week.first.client.name
      puts dev_week.first.type_of_work.name
      dev_week = dev_week.sort_by{|e| [e.developer.first_name, e.client.name, e.type_of_work.name] }

      # dev_name = dev_week[0]["Name"].to_s
      dev = dev_week.first.developer
      dev_name = "#{dev.first_name} #{dev.last_name}"

      assembly = []

      dev_week.each_with_index do |e, i|
        hash = {}
        hash['Date'] = date
        hash['Client Name'] = e.client.name

        hash['Client Name'] = 'Metric Media' if hash['Client Name'] == 'urban business underwriting'

        hash['Updated Description'] = e.type_of_work.name
        hash['Hours'] = e.hours
        hash['Name'] = dev_name
        if dev.upwork
          hash['Employment Classification'] = 'Upwork'
        else
          hash['Employment Classification'] = 'International Contractor'
        end
        if i == 0
          assembly << hash
          next
        end

        prev = assembly[-1]
        if prev['Client Name'] == hash['Client Name']
          if prev['Updated Description'] == hash['Updated Description']
            prev['Hours'] = prev['Hours'].to_f + hash['Hours'].to_f
            # desc = prev['Description'].to_s.gsub(/"/i, '').split("\n")
            # desc << e['Description']
            # desc.uniq!
            # prev['Description'] = "\"#{desc.join("\n")}\""
            assembly[-1] = prev
          else
            assembly << hash
          end
        else
          assembly << hash
        end

      end

      assembly = assembly.map! do |e|
        e['Dept'] = 'RIS'
        puts 'qweqweqweqwe'
        puts e['Client Name']
        if e['Client Name'].to_s.match(/\bL(ocal)?\s*G(overnment)?\s*I(nformation)?\s*S(ervices)?\b/i)
          e['Client Name'] = 'LGIS - Local Government Information Services'
          e['Oppourtunity ID'] = '0061I00000MCMkRQAX'
          e['Oppourtunity Name'] = 'LGIS - 2020'
          e['Old Product Name'] = 'Editorial Data Services'
          e['SF Product ID'] = '01t1I0000032POnQAM'
          e['Account Name'] = 'RIS - Editorial Data Services Cost'
        elsif e['Client Name'].to_s.strip.squeeze(' ').upcase == 'FRANKLIN NEWS FOUNDATION'
          e['Oppourtunity Name'] = 'HYPERLINK("https://na73.lightning.force.com/lightning/r/0061I00000GbU42QAF/view", "Monthly Content - INN")'
          e['Oppourtunity ID'] = '0061I00000MNrruQAD'
          e['Old Product Name'] = 'Editorial Data Services'
          e['Account Name'] = 'RIS - Editorial Data Services Cost'
          e['SF Product ID'] = '00k1I00000ey3euQAA'
        elsif e['Client Name'].to_s.match(/\b(Media Metric|Metric Media|MM)\b/i)
          e['Oppourtunity Name'] = 'Regional News Network - 2020'
          e['Oppourtunity ID'] = '0061I00000MNeo9QAD'
          e['Old Product Name'] = 'Regional News Network | Baseline - 2020'
          e['SF Product ID'] = '01t1I0000032POnQAM'
          e['Client Name'] = 'Metric Media - Donors'
          e['Account Name'] = 'Editorial Data Services'

        elsif e['Client Name'].to_s.strip.squeeze(' ').upcase == 'THE RECORD'
          e['Client Name'] = 'The Record'
          e['Oppourtunity Name'] = '2020 - Document Retrievers'
          e['Oppourtunity ID'] = '0061I00000MNrruQAD'
          e['Old Product Name'] = 'Document Services'
          e['Account Name'] = 'RIS - Editorial Data Services Cost'
          e['SF Product ID'] = '00k1I00000sR3njQAC'

        elsif e['Client Name'].to_s.match(/\bG\s*&\s*A\b/i)
          e['Oppourtunity Name'] = 'Operating Cost - RIS'
          e['Oppourtunity ID'] = 'TBD'
          e['Product Name Per Sales Force'] = 'Custom Data Services'
          # e['Client Name'] = 'Roseland'
          e['Account Name'] = 'RIS - Editorial Data Services Cost'
        end
        e
      end


      puts '1'
      puts assembly
      assembly
      # print "\nSuccess #{dev_name}! Total hours:\t #{total_hours}\n"
      # tsv = ""
      # assembly_headers = ["BLANK COLUMN", "Date", "Dept", "Name", "BLANK COLUMN", "Updated Description", "Oppourtunity Name", "Oppourtunity ID", "Old Product Name", "SF Product ID", "Client Name", "Account Name", "Hours", "BLANK COLUMN", "BLANK COLUMN", "Employment Classification"]
      # assembly.each{|e| tsv += "#{hash_to_tsv(e, assembly_headers)}\n" }
      # to_clip_b(tsv)
      # tsv
    end
  end
end
