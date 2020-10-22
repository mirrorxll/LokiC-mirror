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
      puts 'defeffe'
      return if dev_week.nil?
      dev_week = dev_week.sort_by{|e| [e.developer.first_name, e.client.name, e.type_of_work.name] }
      week = dev_week.first.week
      dev = dev_week.first.developer

      assemblies = []

      dev_week.each_with_index do |e, i|
        hash = {}
        hash['Week'] = week
        hash['Client Name'] = e.client.name

        hash['Client Name'] = 'Metric Media' if hash['Client Name'] == 'urban business underwriting'

        hash['Updated Description'] = e.type_of_work.name
        hash['Hours'] = e.hours
        hash['Developer'] = dev
        # if dev.upwork
        #   hash['Employment Classification'] = 'Upwork'
        # else
        #   hash['Employment Classification'] = 'International Contractor'
        # end
        if i == 0
          assemblies << hash
          next
        end

        prev = assemblies[-1]
        if prev['Client Name'] == hash['Client Name']
          if prev['Updated Description'] == hash['Updated Description']
            prev['Hours'] = prev['Hours'].to_f + hash['Hours'].to_f
            assemblies[-1] = prev
          else
            assemblies << hash
          end
        else
          assemblies << hash
        end

      end

      assemblies = assemblies.map! do |e|
        e['Dept'] = 'RIS'
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

      assemblies.each do |assembly|
        Assembled.create(week: assembly['Week'],
                         dept: assembly['Dept'],
                         developer: assembly['Developer'],
                         updated_description: assembly['Updated Description'],
                         oppourtunity_name: assembly['Oppourtunity Name'],
                         oppourtunity_id: assembly['Oppourtunity ID'],
                         old_product_name: assembly['Old Product Name'],
                         sf_product_id: assembly['SF Product ID'],
                         client_name: assembly['Client Name'],
                         account_name: assembly['Account Name'],
                         hours: assembly['Hours'])
      end

    end
  end
end
