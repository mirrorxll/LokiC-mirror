# frozen_string_literal: true

def account_type
  %w[manager editor developer].map { |type| { name: type } }
end

def account
  [
    {
      first_name: 'Sergey',
      last_name: 'Emelyanov',
      email: 'evilx@lokic.loc',
      password: '123456'
    },
    {
      first_name: 'Dmitriy',
      last_name: 'Buzina',
      email: 'dmitriy.b@lokic.loc',
      password: '123456'
    },
    {
      first_name: 'Sergey',
      last_name: 'Burenkov',
      email: 'serg.burenkov@lokic.loc',
      password: '123456'
    },
    {
      first_name: 'John',
      last_name: 'Putz',
      email: 'john.putz@lokic.loc',
      password: '123456'
    }
  ]
end

def status
  statuses = ['not started', 'in progress', 'exported', 'on cron', 'blocked', 'migrated', 'canceled']
  statuses.map { |st| { name: st } }
end

def frequency
  frequencies = %w[daily weekly monthly quarterly annually biannually irregularly]
  frequencies.map { |fr| { name: fr } }
end

def dates(range: false)
  start = Date.new(2015, 1, 1)
  finish = Date.new(2025, 1, 1)

  range ? start..finish : [start, finish]
end

def types_of_work
  [
    { work: 0, name: 'Data Collection and Processing' },
    { work: 0, name: 'DWYM' },
    { work: 0, name: 'General Management' },
    { work: 0, name: 'G&A Development Services' },
    { work: 0, name: 'G&A Management- Data Services' },
    { work: 0, name: 'Story Production' },
    { work: 0, name: 'Lead Generation' },
    { work: 0, name: 'Data Cleaning' },
    { work: 0, name: 'Roseland MVP' },
    { work: 0, name: 'Cost Of Sales - Ballotpedia' },
    { work: 0, name: 'FOIA Chargers' },
    { work: 0, name: 'Franklin Archer Social Media' },
    { work: 0, name: 'Blockshopper Customer Service' },
    { work: 0, name: "Data Analysis - Voter Profile 'Grid'" },
    { work: 0, name: 'Dev Algo work' },
    { work: 0, name: 'Application Maintenance' },
    { work: 0, name: 'Human Resources - Hiring Skill test' },
    { work: 0, name: 'Matching Algos' },
    { work: 0, name: 'Physical Hardware Cost' },
    { work: 0, name: 'Scrape sourcing, instructions and data review' },
    { work: 0, name: 'Data Collection' },
    { work: 0, name: 'Data Matching' },
    { work: 0, name: 'G&A Management- Human Resources' },
    { work: 0, name: 'Scrape Work' },
    { work: 1, name: %(Scrape) },
    { work: 1, name: %(FOIA Request) },
    { work: 1, name: %(Manual Data Gather) },
    { work: 1, name: %(Marketwatch) },
    { work: 1, name: %(HLE Story Template Creation / Production) },
    { work: 1, name: %(Creation of new client or projects/publications in Pipeline) },
    { work: 1, name: %(Direct data delivery (in a spreadsheet or csv)) },
    { work: 1, name: %(Data to Limpar) },
    { work: 1, name: %(Lumen work) },
    { work: 1, name: %(Tool building, maintenance, or improvement) },
    { work: 1, name: %(Human Resources (hiring, training, writing documentation, etc)) },
    { work: 1, name: %(Report request (e.g., "How many of this or that have we done so far, etc.", "How much did we spend?")) }
  ]
end

def clients_report
  [
    { name: 'AbelsonTaylor' },
    { name: 'All Texas Process Servers' },
    { name: 'American Independent Media' },
    { name: 'Arizona Prosperity Alliance' },
    { name: 'Austin American-Statesman' },
    { name: 'Beaumont Enterprise' },
    { name: 'Berkeley Research Group' },
    { name: 'Configure One' },
    { name: 'Curious Task' },
    { name: 'D181 School Board Campaign' },
    { name: 'Dan Proft' },
    { name: 'Delos Communications' },
    { name: 'Digital Logic' },
    { name: 'DirecTech' },
    { name: 'Edelman' },
    { name: 'Empower Texans' },
    { name: 'Everett Herald' },
    { name: 'File & ServeXpress' },
    { name: 'Financial Poise' },
    { name: 'Fisher Wallace Laboratories' },
    { name: 'Franklin News Foundation' },
    { name: 'Genus Holdings' },
    { name: 'Georgetown Group' },
    { name: 'Google AdSense' },
    { name: 'Grocery Manufacturers Association' },
    { name: 'Heartland Institute' },
    { name: 'Houston Chronicle' },
    { name: 'Hutchinson & Stoy PLLC' },
    { name: 'Illinois Business Alliance' },
    { name: 'Illinois Opportunity Project' },
    { name: 'Illinois Policy Institute' },
    { name: 'Illinois Policy(501c3)' },
    { name: 'IMGE' },
    { name: 'INN-Watchdog.org' },
    { name: 'Iowa Digital Newsboard' },
    { name: 'Ironlight' },
    { name: 'Ives for Illinois' },
    { name: 'Kin' },
    { name: 'Kivvit' },
    { name: 'Liberty Principals PAC' },
    { name: 'Lisa Wagner Co.' },
    { name: 'Litify' },
    { name: 'Local Government Information Services' },
    { name: 'Local Labs' },
    { name: 'Local Labs - Shared Services' },
    { name: 'Metric Media' },
    { name: 'Project 5 Media' },
    { name: 'Real Time Reporters' },
    { name: 'Red Dog Dumpsters' },
    { name: 'Satter Foundation' },
    { name: 'Satter Management' },
    { name: 'Scripps Media' },
    { name: 'Semiotics' },
    { name: 'Shaw Media' },
    { name: 'Shorewood Development Group' },
    { name: 'Situation Management Group' },
    { name: 'Spiegel' },
    { name: 'Steve Lefko - School Board' },
    { name: 'Texas Monitor' },
    { name: 'Texas Public Policy Foundation' },
    { name: 'The Record' },
    { name: 'Tiger Swan' },
    { name: 'Timothy Broas' },
    { name: 'Toba Communications' },
    { name: 'Trident CEO Council' },
    { name: 'Two Dog Blog' },
    { name: 'US Term Limits' },
    { name: 'WV Bar Association' },
    { name: 'Zola Creative' },
    { name: 'Zurich North America' },
    { name: 'Ballotpedia' },
    { name: 'Blockshopper' },
    { name: 'ASC' },
    { name: 'Roseland' },
    { name: 'Situation Management Group (SMG)' },
    { name: 'Broomfield, CO - Big Dog Promotion' },
    { name: 'G&A Management- Data Services' },
    { name: 'G&A Development Services' },
    { name: 'Lumen' },
    { name: 'G&A Management- Human Resources' },
    { name: 'urban business underwriting' },
    { name: 'catholic vote' }
  ]
end

def task_reminder_frequency
  frequencies = ['each day', 'once a week', 'two times a week', 'three times a week',
                 'each Monday', 'each Tuesday', 'each Wednesday', 'each Thursday', 'each Friday', 'each Saturday', 'each Sunday']
  frequencies.map { |fr| { name: fr } }
end

account_type.each { |obj| AccountType.create!(obj) }
account.each { |obj| Account.create!(obj).account_types << AccountType.first }
frequency.each { |obj| Frequency.create!(obj) }
status.each { |obj| Status.create!(obj) }
types_of_work.each { |obj| WorkType.create!(obj) }
clients_report.each { |obj| ClientsReport.create!(obj) }
task_reminder_frequency.each { |obj| TaskReminderFrequency.create!(obj) }


ClientsPublicationsTagsJob.perform_now
ClientsTagsJob.perform_now
SectionsJob.perform_now
PhotoBucketsJob.perform_now
SlackAccountsJob.perform_now

hidden = Client.where('name LIKE :like OR name IN (:mm, :mb)',
                      like: 'MM -%', mm: 'Metric Media', mb: 'Metro Business Network')
hidden.update_all(hidden_for_story_type: false)

# ============ Time Frames for staging tables ============
puts 'Time Frames'
# daily
dates(range: true).each do |dt|
  TimeFrame.create!(frame: "d:#{dt.yday}:#{dt.year}")
end

# weekly
date, end_date = dates
loop do
  TimeFrame.create!(frame: "w:#{date.cweek}:#{date.year}")
  date += 7
  break if date > end_date
end

# monthly
date, end_date = dates
loop do
  TimeFrame.create!(frame: "m:#{date.month}:#{date.year}")
  date = date.next_month
  break if date > end_date
end

# quarterly
date, end_date = dates
loop do
  (1..4).each { |q| TimeFrame.create!(frame: "q:#{q}:#{date.year}") }
  date = date >> 3
  break if date > end_date
end

# biannually
date, end_date = dates
loop do
  (1..2).each { |b| TimeFrame.create!(frame: "b:#{b}:#{date.year}") }
  date = date >> 6
  break if date > end_date
end

# annually
date, end_date = dates
loop do
  TimeFrame.create!(frame: date.year)
  date = date.next_year
  break if date > end_date
end

begin_date = Date.parse('2020/01/06')
end_date = Date.parse('2020/01/12 23/59/59')
110.times do
  Week.create(begin: begin_date, end: end_date)
  begin_date += 7
  end_date += 7
end

# ============ FeedBack rules for stories ============
rules = {
  'capital_letters' => {
    'Four or more capital letters in row' => 'Show the capitalized sequence of characters and recommend a discussion with John about whether normalization of the words or phrases in that variable spot should be performed.'
  },
  'single_digits' => {
    'Single-digit numbers(1..9)' => 'Single-digit numbers between 1 and 9 should be written out, like this: "one", "two", "three", etc. Apply the correct method to make this happen.'
  },
  'dollar_with_cents' => {
    'Dollar amounts with cents' => "We almost never use decimals for dollar amounts in stories. So, $153.51 => $154 in the story and table. Note: if the story body gives a total dollar amount, and the table gives each value used to get the total, then when we round, we may end up saying, for example, that the total is $1,005 when the sum of the rounded amounts in the table does not match this exactly. If that happens, then in the story, say 'about $1,005'"
  },
  'percentage_with_sign' => {
    'Percentages with % sign' => 'Percent signs should appear only in tables. In the body of the story or headlines, we use the word percent. For example: 92.3% should become 92.3 percent'
  },
  'headline_length' => {
    'Headline length' => 'You have a really long headline here. Is it including weird information (such as an unnecessary city and state name, gibberish, or anything odd?)? Does it look ok? Is there a way to shorten it without making it look strange? Ask John if you have doubts.'
  },
  'capitalized_single_letter' => {
    'Capitalized single letters' => 'In English, the word I and the word A (at the beginning of a sentence) can be capitalized without a period. But initials in names or abbreviations of directions always_ need a period. John M. Smith (NOT: John M Smith), 123 E. Main Road (NOT: 123 E Main Road), B.B. King (NOT: B B King)'
  },
  'all_two_of' => {
    'All of two/2' => '"all 2 of" or "all two of" => "both of"'
  },
  'decimal_with_zero' => {
    'Decimal with zero' => 'Make sure that your story will not show final digits or decimals if it is zero. 50.0 percent => 50 percent, 43.20 => 43.2 etc.'
  },
  'contractions' => {
    'English contractions' => "Do not include contractions in news stories unless they are in quotations from other sources. Otherwise, write them out. So: didn't => did not, can't => cannot, etc."
  },
  'state_abbreviations' => {
    'State abbreviations' => "States should be abbreviated in AP style in tables only. In the body of the story, state names should be spelled out completely. So, 'CO' or 'Colo.' should be come 'Colorado'"
  },
  'st_ave_blvd_abbreviations' => {
    'Street/Avenue/Boulevard' => "The words 'Street', 'Avenue', and 'Boulevard' should be abbreviated in a numbered address. Example: 123 Main St., 789 Yellow Ave., 456 Big Bend Blvd.. They should be spelled out if there is no numbered address. Example: 'We live on Main Street.'"
  },
  'other_address_abbreviations' => {
    'Other address abbreviations' => "You have a type of street name abbreviated. For example, 'Rd' or 'Ln'. All types of street names should be spelled out in AP style with very few exceptions. The words 'Street', 'Avenue', and 'Boulevard' should be abbreviated in a numbered address. Example: 123 Main St., 789 Yellow Ave., 456 Big Bend Blvd.. They should be spelled out if there is no numbered address. Example: 'We live on Main Street."
  },
  'correct_zip_code' => {
    'Zip codes' => 'It appears that your story has zip codes mentioned in it. Some zip codes in the U.S. begin with "0", such as "02325". Make sure that your stories about these zip codes will not cut off the 0. This can happen when zip codes are stored in int fields in MySQL tables, etc. All zip codes must have 5 digits.'
  },
  'usage_verb_have_has' => {
    'Have/has' => 'You are using have/has in the first paragraph of the story. Make sure that, if there will be stories with plural/singular subjects, the story uses the plural/singular verb, has/have.'
  },
  'usage_verb_is_are' => {
    'Is/are' => 'You are using is/are in the first paragraph of the story. Make sure that, if there will be stories with singular/plural subjects, the story uses the singular/plural verb, are/is.'
  },
  'usage_verb_was_were' => {
    'Was/were' => 'You are using was/were in the first paragraph of the story. Make sure that, if there will be stories with singular/plural subjects, the story uses the singular/plural verb, were/was.'
  },
  'more_one_dig_after_point' => {
    'More one digits after point' => 'Pay attention to the number of numbers after the point. In general cases, there should be no more than one digit after point. I advise you to discuss this with John.'
  },
  'negative_amount' => {
    'Negative dollar amount' => "We can't show a negative dollar amount in this form ($-123). Discuss this with John."
  },
  'district_of_columbia' => {
    'District of Columbia' => 'Note, stories tell about the states. If you create stories for the District of Columbia in the headline indicate "D.C." instead of "District of Columbia", and in the teaser be sure to add the article "The" or "the" (ex: The District of Columbia)'
  },
  'increase_over' => {
    'Increase over' => 'If there is a "decrease" in the stories, please check that this part of the sentence looks like "decrease from", not "decrease over".'
  },
  'decrease_over' => {
    'Decrease over' => 'Change this part to "decrease from". So, "decrease over" => "decrease from".'
  },
  'ordinal_numbers' => {
    'Ordinal numbers' => "You have a ranking (or ordinal number -- first, 11th, 12th, etc.) in this story. Make sure that:\n1. all numbers with two or more digits that end in a 1, except 11, use 'st'. Ex: first, 11th, 21st, 31st, 151st, 1,191st, etc.\n2. all numbers with two or more digits that end in a 2, except 12, use 'nd'. Ex: second, 12th, 22nd, 32nd, 152nd, 1,192nd, etc.\n3. all numbers with two or more digits that end in a 3, except 13, use 'rd'. Ex: third, 13th, 23rd, 33rd, 153rd, 1,193rd, etc.\n4. All other numbers use 'th'. Ex: 4th, 28th, 87th, etc."
  },
  'city_from_another_state' => {
    'City from another state' => "Note: state names should be mentioned after the city only if the state is different from the publication state. So if it is an Illinois publication, we don't ever say, 'City, Illinois'. We just say 'City'"
  },
  'comma_after_state_name' => {
    'Comma after a city name' => "Remember to put a comma after the state name, too, the sentence continues. Example: '... in Springfield, Illinois, on Feb. 10' is correct. '... in Springfield, Illinois on Feb. 10' is incorrect.)"
  },
  'the_locality_of' => {
    'The "locality" of' => "It is almost always a bad idea to say 'the city of', 'the town of', or 'the village of' before a name. Delete that. Bad: '10 people in the 'city of Springfield lost 5 pounds.' Good: '10 people in Springfield lost 5 pounds."
  },
  'the_county_of' => {
    'The county of' => "It is almost always better to write county names as 'Name County' than to say 'the County of Name'. Examples: the County of St. Louis should be St. Louis County"
  },
  'washington_in_headline' => {
    'Washington' => "If Washington is referring to the state (and not a city), then use 'the state of Washington'"
  },
  'new_york_in_headline' => {
    'New York' => "If New York is referring to the state (and not the city), then use 'New York state'"
  },
  'number_with_comma' => {
    'Number with comma' => "It appears that you have some numbers in this story. Remember that any number greater than 999 must have commas -- unless they are in addresses. So, for example, $1000 should be $1,000. If there were 2532 people in a group, it should be written as '2,532 people', etc."
  },
  'sentence_with_one' => {
    'Word "one" in text' => "When there is only 'one' (1) of something, you may need to change the sentence. Watch for these mistakes: 'All one of the homes/pensioners/retirees/etc....' will usually become 'The only home/pensioner/retiree/etc....', 'One homes/pensioners/retirees/etc. were...' will become 'One home/pensioner/retiree/etc. was...', etc. In particular, you want to make sure that plural nouns become singular if there is only one of them, and you need to make sure relevant verbs are singular, too. ('has' rather than 'have', 'was' rather than 'were', etc.)"
  }
}

puts 'Auto-feedback'
rules.each { |rule, output| AutoFeedback.create!(rule: rule, output: output) }
