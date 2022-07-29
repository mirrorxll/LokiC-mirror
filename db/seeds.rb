# frozen_string_literal: true

def roles
  [
    'Manager',
    'Content Manager',
    'Content FCD Checker',
    'Content Data Cleaner',
    'Content Developer',
    'Scrape Manager',
    'Scrape Data Reviewer',
    'Scrape Developer',
    'Client',
    'Guest'
  ]
end

def branches
  %w[
    work_requests
    factoid_requests
    multi_tasks
    scrape_tasks
    data_sets
    story_types
    factoid_types
  ]
end

def access_levels
  %w[manager user guest]
end

def frequency(db02)
  query = 'SELECT name FROM frequencies;'
  db02.query(query).to_a
end

def state(db02)
  query = 'SELECT full_name, short_name  FROM states;'
  db02.query(query).to_a
end

def data_set_category(db02)
  query = 'SELECT name, note FROM data_set_categories;'
  db02.query(query).to_a
end

def status(db02)
  query = 'SELECT name FROM statuses;'
  db02.query(query).to_a + [{ name: 'active' }, { name: 'deactivated' }]
end

def level(db02)
  query = 'SELECT name FROM levels;'
  db02.query(query).to_a
end

def work_type(db02)
  query = 'SELECT work, name, hidden FROM work_types;'
  db02.query(query).to_a
end

def underwriting_project(db02)
  query = 'SELECT name, hidden FROM underwriting_projects;'
  db02.query(query).to_a
end

def revenue_type(db02)
  query = 'SELECT name, hidden FROM revenue_types;'
  db02.query(query).to_a
end

def priority(db02)
  query = 'SELECT name FROM priorities;'
  db02.query(query).to_a
end

def invoice_type(db02)
  query = 'SELECT name, hidden FROM invoice_types;'
  db02.query(query).to_a
end

def invoice_frequency(db02)
  query = 'SELECT name, hidden FROM invoice_frequencies;'
  db02.query(query).to_a
end

def task_reminder_frequency(db02)
  query = 'SELECT name FROM task_reminder_frequencies;'
  db02.query(query).to_a
end

def weeks(db02_sec)
  query = 'SELECT begin, end FROM weeks;'
  db02_sec.query(query).to_a
end

def dates(range: false)
  start = Date.new(2015, 1, 1)
  finish = Date.new(2025, 1, 1)

  range ? start..finish : [start, finish]
end

# ============ Initial filling DB ============
db02 = MiniLokiC::Connect::Mysql.on(DB02, 'lokic')
db02_sec = MiniLokiC::Connect::Mysql.on(DB02, 'lokic_secondary')

puts 'Account Roles/Branches'
roles.each { |role| AccountRole.find_or_create_by!(name: role) }
branches.each do |branch_name|
  branch = Branch.find_or_create_by!(name: branch_name)

  access_levels.each do |lvl_name|
    AccessLevel.find_or_create_by!(
      branch: branch,
      name: lvl_name,
      permissions: AccessLevels::PERMISSIONS[lvl_name][branch_name],
      lock: true
    )
  end
end

puts 'Frequencies'
frequency(db02).each { |obj| Frequency.find_or_create_by!(obj) }

puts 'States'
state(db02).each { |obj| State.find_or_create_by!(obj) }

puts 'Data Set Categories'
data_set_category(db02).each { |obj| DataSetCategory.find_or_create_by!(obj) }

puts 'Statuses'
status(db02).each { |obj| Status.find_or_create_by!(obj) }

puts 'Levels'
level(db02).each { |obj| Level.find_or_create_by!(obj) }

puts 'Fact Checking Channels'
Account.all.each { |acc| acc.create_fact_checking_channel(name: "fcd_#{acc.first_name.downcase}_#{acc.last_name.downcase}") }

puts 'Work Types'
work_type(db02).each { |obj| WorkType.find_or_create_by!(obj) }

puts 'Underwriting Projects'
underwriting_project(db02).each { |obj| UnderwritingProject.find_or_create_by!(obj) }

puts 'Revenue Types'
revenue_type(db02).each { |obj| RevenueType.find_or_create_by!(obj) }

puts 'Priorities'
priority(db02).each { |obj| Priority.find_or_create_by!(obj) }

puts 'Invoice Types'
invoice_type(db02).each { |obj| InvoiceType.find_or_create_by!(obj) }

puts 'Invoice Frequencies'
invoice_frequency(db02).each { |obj| InvoiceFrequency.find_or_create_by!(obj) }

puts 'MultiTask Reminder Frequencies'
task_reminder_frequency(db02).each { |obj| TaskReminderFrequency.find_or_create_by!(obj) }

puts 'Weeks'
weeks(db02_sec).each { |obj| Week.find_or_create_by!(obj) }

unless Account.first
  puts 'First Account'
  Account.reset_column_information
  Account.create(
    email: 'lokic@locallabs.com',
    first_name: 'Loki',
    last_name: 'C',
    password: SecureRandom.hex(3)
  )
end

db02.close
db02_sec.close

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
rules.each { |rule, output| AutoFeedback.find_or_create_by!(rule: rule, output: output) }

puts 'Hosts/Schemas/Tables'
%w[DB01 DB02 DB04 DB06 DB07 DB08 DB10 DB13 DB14 DB15].each { |h| Host.find_or_create_by(name: h) }
SchemasTablesTask.new.perform

puts 'Clients/Publications/Tags/Sections'
ClientsPubsTagsSectionsTask.new.perform
Client.where(
  'name LIKE :like OR name IN (:mm, :mb)',
  like: 'MM -%', mm: 'Metric Media',
  mb: 'Metro Business Network'
).update_all(hidden_for_story_type: false, hidden_for_work_request: false)

puts 'PhotoBuckets'
PhotoBucketsTask.new.perform

puts 'Opportunities'
OpportunitiesTask.new.perform

puts 'SlackAccounts'
SlackAccountsJob.new.perform
