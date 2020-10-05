def to_clip_b(txt)
  `echo '#{txt.to_s}' | xclip -selection clipboard`
end

def tsv_to_hash(tsv, headers)
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

def hash_to_tsv(hash, headers)
  tsv = ""
  headers.each do |head|
    tsv += "#{hash[head]}\t"
  end
  tsv
end

@contractors = ['Alberto Egurrola', 'Alex Bokow', 'Andrey Nagorniy', 'Andrey Tereshchenko', 'Art Jarocki', 'Dmitiry Suschinsky', 'Dmitriy Shilenko', 'Dmitry Danitov', 'Muhammad Adeel Anwar', 'Oleh Burenkov', 'Sergey Burenkov', 'Sergii Butrymenko', 'Yunus Ganiyev', 'Igor Lobazov']

@upwork = ['Alexandr Kuzmenko', 'Anton Storchak', 'Aqeel Anwar', 'Burak Kaymakci', 'Daniel Moskalchuk', 'Dmitriy Buzina', 'Dmitry Kachalov', 'Halyna Merkotan', 'Jim Whisler', 'Sergey Emelyanov']

def q(tsv)
  headers = ["Name", "Hours", "Updated Description", "Client Name", "(SKIP COLUMN)", "Date", "(SKIP COLUMN)", "(SKIP COLUMN)", "Employment Classification", "Description"]
  dev_hash = tsv_to_hash(tsv, headers)
  dev_hash = dev_hash.sort_by{|e| [e['Name'], e['Client Name'], e['Updated Description']]}

  total_hours = 0
  dev_name = dev_hash[0]["Name"].to_s

  assembly = []
  dev_hash.each_with_index do |e, i|
    total_hours += e["Hours"].to_f
    e['Client Name'] = e['Client Name'].strip.squeeze(' ')

    e['Client Name'] = 'Metric Media' if e['Client Name'] == 'urban business underwriting'

    e['Name'] = e['Name'].to_s.strip.squeeze(' ')
    if @contractors.include?(e['Name'])
      e['Employment Classification'] = 'International Contractor'
    elsif @upwork.include?(e['Name'])
      e['Employment Classification'] = 'Upwork'
    end
    if i == 0
      assembly << e
      next
    end

    prev = assembly[-1]
    if prev['Client Name'] == e['Client Name']
      if prev['Updated Description'] == e['Updated Description']
        prev['Hours'] = prev['Hours'].to_f + e['Hours'].to_f
        desc = prev['Description'].to_s.gsub(/"/i, '').split("\n")
        desc << e['Description']
        desc.uniq!
        prev['Description'] = "\"#{desc.join("\n")}\""
        assembly[-1] = prev
      else
        assembly << e
      end
    else
      assembly << e
    end

  end

  assembly = assembly.map! do |e|
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

  print "\nSuccess #{dev_name}! Total hours:\t #{total_hours}\n"
  tsv = ""
  assembly_headers = ["BLANK COLUMN", "Date", "Dept", "Name", "BLANK COLUMN", "Updated Description", "Oppourtunity Name", "Oppourtunity ID", "Old Product Name", "SF Product ID", "Client Name", "Account Name", "Hours", "BLANK COLUMN", "BLANK COLUMN", "Employment Classification"]
  assembly.each{|e| tsv += "#{hash_to_tsv(e, assembly_headers)}\n" }
  to_clip_b(tsv)
  # tsv
end
