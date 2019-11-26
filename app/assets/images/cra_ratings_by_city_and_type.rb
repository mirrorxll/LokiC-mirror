# frozen_string_literal: true

def get_type(num)
  t = [
    'OUTSTANDING',
    'SATISFACTORY',
    'NEEDS TO IMPROVE',
    'SUBSTANTIAL NONCOMPLIANCE'
  ]

  t[num - 1]
end

def mm_client_ids
  '152,153,154,155,156,157,158,159,160,161,162,163,164,165,166'
end

def number_to_money(value, suffix = '')
  if value >= 10 ** 9
    value = (value.to_f / (10 ** 9)).round(2)
    suffix = ' billion' if suffix.eql?('')
  elsif value >= 10 ** 6
    value = (value.to_f / (10 ** 6)).round(2)
    suffix = ' million' if suffix.eql?('')
  elsif value >= 10 ** 3
    value = (value.to_f / (10 ** 3)).round(2)
    suffix = ' thousand' if suffix.eql?('')
  end
  value = "#{value.to_f < 0 ? '-' : ''}#{Numbers::money(value.to_f).to_s}"
  value.index('.') ? "#{value.sub(/0$/, '').sub(/0$/, '').sub(/\.$/, '')}#{suffix}" : "#{value}#{suffix}"
end

def get_table(banks)
  banks.map do |bank|
    {
      'Bank Name' => bank['clean_bank_name'],
      'Exam Date' => bank['exam_date'].strftime('%D'),
      'Asset Size' => number_to_money(bank['assest_size'] * 1000)
    }
  end
end

def clean_city_name(city)
  city.split.map do |part|
    part =~ /-/ ? part.split('-').map(&:capitalize).join('-') : part.capitalize
  end.join(' ')
end

def hle_cra_ratings_by_city_and_type_stage_population(line, arguments)
  db05 = Route_noprefix.new(host: DB05, stage_db: 'loki_storycreator')
  db13 = Route_noprefix.new(host: DB13, stage_db: 'usa_raw')

  cities_states = db13.client.query(%(
    select distinct city,
                    full_state state,
                    pl_production_org_id org_id
    from #{db13.stage_db}.cra_ratings
    where good_for_story = 1 and
          pl_production_org_id is not null;)).to_a

  cities_states.each do |city_state_id|
    city = city_state_id['city']
    state = city_state_id['state']
    org_id = city_state_id['org_id']

    puts '------------'
    puts city, state
    puts '------------'

    (1..4).each do |num|
      banks = db13.client.query(%(
        select *
        from #{db13.stage_db}.cra_ratings
        where city = "#{city}" and
              full_state = '#{state}' and
              rating = #{num} and
              good_for_story = 1;)).to_a
      next if banks.count.zero?

      type = get_type(num)
      table = get_table(banks)
      num_of_banks = banks.count
      # publications = get_journal_from_org_id(org_id, 'production', mm_client_ids)

      publication = {
        'id' => 655,
        'publication_name' => 'Keystone Business News',
        'client_id' => 120,
        'client_name' => 'Metro Business Network'
      }

      # publications.each do |publication|
        hash = {}

        hash['publication_name'] = publication['publication_name']
        next if hash['publication_name'].empty?

        hash['client_name'] = publication['client_name']
        hash['publication_id'] = publication['id']
        hash['organization_id'] = org_id
        hash['source_table_id'] = 19748
        hash['client_id'] = publication['client_id']
        hash['source_id'] = hash['source_table_id'] * 1_000_000_000 +
                            publication['id'].to_i * 10_000_000 +
                            city.bytes.reduce(:+) + state.bytes.reduce(:+) +
                            type.bytes.reduce(:+)

        hash['city'] = clean_city_name(city)
        hash['state'] = state
        hash['rating_type'] = type.downcase
        hash['story_table'] = table.to_json
        hash['number_of_banks'] = num_of_banks

        rules = insert_rules(hash.escaped)
      query = "insert into #{db05.stage_db}.#{@config['target_table']}#{rules}"
      puts query
        db05.client.query(query)
      # end
    end
  end

  db05.client.close if db05
  db13.client.close if db13
end

def hle_cra_ratings_by_city_and_type_story_creation(options)
  @stage_selection.each do |stage|
    export = {}

    city = stage['city']
    state = stage['state']
    rating_type = stage['rating_type']
    number_of_banks = stage['number_of_banks']
    table = graph_from_json(stage['story_table'])

    export['headline'] = %(#{number_of_banks} bank#{number_of_banks > 1 ? 's' : '' } in #{city} rated as "#{rating_type}" by feds)
    export['teaser'] = %(A total of #{number_of_banks < 10 ? Numbers.in_words(number_of_banks) : number_of_banks} )
    export['teaser'] += %(bank#{number_of_banks > 1 ? 's' : '' } in #{city}, #{state} have been rated as "#{rating_type}" by federal regulators.)

    output = %(#{export['teaser']}\n\n)
    output += %(<a href='https://www.federalreserve.gov/consumerscommunities/cra_about.htm'>Under the Consumer Reinvestment Act (CRA) of 1977</a>, )
    output += %(federally insured banks in the United States are required to meet the credit needs of the entire community in which they serve -- )
    output += %(including low- and moderate-income community members -- through the use of safe and sound banking operations.\n\n)
    output += %(CRA evaluations are meant to ensure financial institutions are meeting these expectations.\n\n)
    output += %(The Federal Reserve Board (FRB) and The Federal Deposit Insurance Corporation )
    output += %((<a href='https://www5.fdic.gov/crapes/'>FDIC</a>) )
    output += %(oversee evaluations of state-chartered financial institutions. Evaluations for national banks are handled by the Office of the Comptroller of the Currency )
    output += %((<a href='https://apps.occ.gov/crasearch/default.aspx'>OCC</a>).\n\n)
    output += %(Regulators follow one of three evaluation plans based on the institution's size, including: large banks with $1.25 billion in assets )
    output += %((investment test, lending test and service test); intermediate banks with at least $313 million in assets but less than $1.25 billion )
    output += %((lending test and community development test); and small banks for institutions with less than $313 million in assets (streamlined lending test).\n\n)
    output += %(At a financial institution's request, regulators will alternatively offer evaluations based on community development (business strategy) )
    output += %(for wholesale and limited purpose banks; and strategic plans (open to any bank).\n\n)
    output += %(<strong style='font-size: 18px;'>#{city} Banks Receiving CRA Rating of #{rating_type}</strong>\n)

    output += table
    prepare_output(stage, output, export, options)
  end
end
