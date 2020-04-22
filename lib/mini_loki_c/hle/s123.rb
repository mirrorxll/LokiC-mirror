module S123
  STAGE_TABLE = 'story_type_fec_biannual_staging'
  def self.get_table(donations)
    table = []

    donations = donations.group_by { |d| [d['name'], d['date']] }.map do |k,v|
      { 'name' => k[0], 'date' => k[1], 'amount' => v.map { |a| a['amount'] }.inject(:+) }
    end

    donations = donations.count >= 200 ? donations.sort_by { |t| [t['amount'], t['date']] }.reverse.first(100) : donations.sort_by { |t| [t['date'], t['amount']] }.reverse

    donations.each do |donation|
      next if donation['name'].nil?
      table << {
          "Contributor" => donation['name'],
          "Amount" => "$#{Numbers.numbers_add_commas(donation['amount'].to_i)}",
          "Date" => donation['date']
      }
    end
    table
  end

  def self.get_date(half, year)
    return { begin: "#{year}-01-01", end: "#{year}-06-30" } if half == 1
    { begin: "#{year}-07-01", end: "#{year}-12-31" }
  end

  def self.population(options)
    data_route = MiniLokiC::Connect::Mysql.on(DB15,'usa_raw')
    delivery = MiniLokiC::Connect::Mysql.on(DB05,'loki_storycreator')

    year = options['year'].to_i
    half = options['half'].to_i
    state = options['state']

    date = get_date(half, year)

    query_for_cmtes = %(select cmte_id,
                             ifnull(cmte_name_cleaned_manually, cmte_name_cleaned_auto) as cmte_name,
                             cand_name_clear as cand_name,
                             pl_production_org_id
                      from fec_campaign_finance_committee_master_uniq cmte left outer join fec_campaign_finance_candidate_master_clear cand on cmte.cand_id = cand.CAND_ID
                      where cmte_st = '#{state}' and
                            bad_cmte = 0
                      group by cmte_id;)

    cmtes = data_route.query(query_for_cmtes)
    puts 'CMTE'
    puts cmtes

    reasons = {
        not_all_data: [],
        publications: []
    }

    i = 0
    total = cmtes.count
    puts 'TOTAL'
    puts total
    cmtes.each do |cmte|
      i += 1
      puts "#{i}/#{total} - processing: #{cmte['cmte_name']}"

      query_for_donations = %(select *
                          from (select ctrb.name_clear name,
                                       ctrb.TRANSACTION_AMT amount,
                                       ctrb.TRANSACTION_DT date
                                from fec_campaign_finance_by_individuals_new ctrb
                                       join (select max(id) id
                                             from fec_campaign_finance_by_individuals_new sub_ctrb
                                                    join fec_campaign_finance_transact_type_codes sub_tr_cd
                                                      on sub_ctrb.TRANSACTION_TP = sub_tr_cd.transaction_type
                                             where sub_ctrb.ENTITY_TP = 'IND' and
                                                   sub_ctrb.cmte_id = '#{cmte['cmte_id']}' and
                                                   sub_ctrb.TRANSACTION_DT between '#{date[:begin]}' and '#{date[:end]}' and
                                                   sub_tr_cd.is_refund = 0
                                             group by sub_ctrb.TRAN_ID) t1
                                         on t1.id = ctrb.id
                                where ctrb.AMNDT_IND != 'T') t2;)

      donations = data_route.query(query_for_donations)
      next if donations.count == 0

      publications = get_journal_from_org_id(cmte['pl_production_org_id'], 'production', 120)
      publications += get_journal_from_org_id(cmte['pl_production_org_id'], 'production', 91)
      # publications += Hle::Publications.mm_pubs_excluding_states(cmte['pl_production_org_id'], 'production', 'Illinois')

      total_amount = donations.map { |t| t['amount'] }.sum

      donations_group = donations.group_by { |d| d['name'] }.map do |k,v|
        { name: k, amount: v.map { |a| a['amount'] }.inject(:+) }
      end
      most_amount = donations_group.sort_by {|d| d[:amount]}.reverse.first(2)

      if most_amount.count > 1 && most_amount[0][:amount] > most_amount[1][:amount]
        name_the_most_contributor = most_amount[0][:name]
        the_most_amount = most_amount[0][:amount]
      end

      data_table = get_table(donations)

      publications.each do |publication|
        hash = {}
        hash['publication_name'] = "#{publication['publication_name']}"
        if hash['publication_name'] == ''
          reasons[:publications] << cmte['cmte_name']
          next
        end

        hash['client_id'] = publication['client_id']
        hash['client_name'] = publication['client_name']
        hash['publication_id'] = publication['id']
        hash['source_table_id'] = 19877
        hash['organization_id'] = cmte['pl_production_org_id']

        hash['year'] = year
        hash['half'] = half
        hash['cmte_name'] = cmte['cmte_name']
        hash['cand_name'] = cmte['cand_name']
        hash['total_amount'] = total_amount
        hash['count_donations'] = donations.count
        hash['name_the_most_contributor'] = name_the_most_contributor
        hash['the_most_amount'] = the_most_amount

        hash['story_table'] = data_table.to_json

        puts hash
        rules = insert_rules(hash.escaped)
        query = "insert into #{STAGE_TABLE}#{rules}"
        p query
        delivery.query(query)
      end
    end
    p 'Final statistics:', reasons
    delivery.client.close if delivery
    data_route.client.close if data_route
    # data_route.web_client.close if data_route
    'INVALID'
  end

  def self.number_to_money_text(value)
    billion = value / 1000000000.0
    million = value / 1000000.0
    if billion >= 1
      value = "$#{Numbers.numbers_add_commas(billion.to_f.round(1)).sub(/\.0$/, '')} billion"
    elsif million >= 1
      value = "$#{million.to_f.round(1).to_s.sub(/\.0$/, '')} million"
    else
      value = "$#{Numbers.numbers_add_commas(value)}"
    end
    value
  end

  def self.half_to_text(half)
    return 'January to June' if half == 1
    'July to December'
  end

  def self.creation(options)
    i = 0
    stages = MiniLokiC::Creation::StagingRecords[STAGE_TABLE]

    count = stages.count

    stages.each do |stage|
      i += 1
      p "\r#{i}/#{count}: \n"
      export = {}

      publication_name = stage['publication_name']

      year = stage['year']
      half = stage['half']

      puts half
      cmte_name = stage['cmte_name']
      cand_name = stage['cand_name']
      total_amount = number_to_money_text(stage['total_amount'])
      name_the_most_contributor = stage['name_the_most_contributor']
      the_most_amount = number_to_money_text(stage['the_most_amount'])
      with_name = cand_name.split(' ').any? { |word| cmte_name.include? word }
      half = half_to_text(half)
      puts half
      table = JSON.parse(stage['story_table'])
      count_donations = stage['count_donations']
      table = "#{graph_from_json(table.to_json)}"

      if with_name
        export['headline'] = "#{cand_name.end_with?('s') ? "#{cand_name}" + "'" : "#{cand_name}" + "'s"} campaign committee receives #{total_amount} from #{half} #{year}"

        export['teaser'] = "#{cand_name.end_with?('s') ? "#{cand_name}" + "'" : "#{cand_name}" + "'s"} campaign committee, #{cmte_name}, received #{total_amount} from #{half} #{year}."

        output = "#{cand_name.end_with?('s') ? "#{cand_name}" + "'" : "#{cand_name}" + "'s"} campaign committee, #{cmte_name}, received #{total_amount} from #{half} #{year}, according to data from the <a href=\"https://www.fec.gov/data/committee/C00629527/?tab=filings\">Federal Election Commission</a>.\n\n"
      else
        export['headline'] = "#{cmte_name} receives #{total_amount} from #{half} #{year}"

        export['teaser'] = "#{cmte_name} received #{total_amount} from #{half} #{year}."

        output = "#{cmte_name} received #{total_amount} from #{half} #{year}, according to data from the <a href=\"https://www.fec.gov/data/committee/C00629527/?tab=filings\">Federal Election Commission</a>.\n\n"
      end

      output << "#{name_the_most_contributor} contributed the most with a total amount of #{the_most_amount}.\n\n" if name_the_most_contributor != ''

      output << "The Federal Election Commission (FEC) is the independent regulatory agency charged with administering and enforcing the federal campaign finance law. The FEC has jurisdiction over the financing of campaigns for the U.S. House, Senate, Presidency and the Vice Presidency.\n\n"

      if count_donations >= 200
        output << %(<strong style="font-size: 18px;">Top 100 donations made to #{cmte_name} during #{half} #{year}</strong>)
      elsif count_donations == 1
        output << %(<strong style="font-size: 18px;">Donation made to #{cmte_name} during #{half} #{year}</strong>)
      else
        output << %(<strong style="font-size: 18px;">Donations made to #{cmte_name} during #{half} #{year}</strong>)
      end

      output << table

      MiniLokiC::Creation::Story.new(STAGE_TABLE, stage, export, output)
    end
  end
end
