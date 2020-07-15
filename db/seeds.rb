# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

module FirstObjects # :nodoc:
  extend self

  def account_type
    %w[super-user manager editor developer].map { |type| { name: type } }
  end

  def account
    [
      {
        first_name: 'Sergey',
        last_name: 'Emelyanov',
        account_type: AccountType.first,
        email: 'evilx@loki.com',
        password: '123456'
      },
      {
        first_name: 'Dmitriy',
        last_name: 'Buzina',
        account_type: AccountType.first,
        email: 'dmitriy.b@loki.com',
        password: '123456'
      },
      {
        first_name: 'Sergey',
        last_name: 'Burenkov',
        account_type: AccountType.first,
        email: 'serg.burenkov@lokic.com',
        password: '123456'
      },
      {
        first_name: 'John',
        last_name: 'Putz',
        account_type: AccountType.first,
        email: 'john.putz@lokic.com',
        password: '123456'
      }
    ]
  end

  def data_set
    [
      {
        account: Account.first,

        name: 'Gas Buddy',
        src_address: 'https://www.gasbuddy.com/',
        src_explaining_data: 'https://source.explaining.data',
        src_release_frequency: Frequency.first,
        src_scrape_frequency_manual: 'daily',
        cron_scraping: true,

        location: 'db12.usa_raw.gasbuddy_%',
        evaluation_document: 'http://evaluation.document',
        evaluated: true,
        evaluated_at: DateTime.now,

        scrape_developer: 'Vlad Sviridov',
        comment: 'bla bla bla',
        gather_task: 'https://gather.task'
      }
    ]
  end

  def status
    statuses = ['not started', 'in progress', 'exported', 'on cron', 'blocked']
    statuses.map { |status| { name: status } }
  end

  def story_type
    [
      {
        name: 'Story Type 1',
        editor: Account.first,
        data_set: DataSet.first
      },
      {
        name: 'Story Type 2',
        editor: Account.first,
        developer: Account.first,
        data_set: DataSet.last
      }
    ]
  end

  def frequency
    frequencies = ['daily', 'weekly', 'monthly', 'quarterly', 'annually', 'manual input']
    frequencies.map { |frequency| { name: frequency } }
  end

  def review
    table_raw_source = []
    table_mm = {}
    published_by_month = {}
    exported_by_month = {}
    arr_mm = []
    (1..12).each do |i|
      rand_num = rand(10000).to_s
      arr_mm << { month: Date::MONTHNAMES[i],
                  total_exported: rand_num,
                  total_published: rand_num }
      rand_raw = rand(100)
      published_by_month["raw_source#{rand_raw}"] = rand_num
      exported_by_month["raw_source#{rand_raw}"] = rand_num
      table_raw_source << {
        month: Date::MONTHNAMES[i],
        published: published_by_month,
        exported: exported_by_month
      }
    end
    table_mm["#{Date.today.strftime("%Y-%m-%d")}"] = arr_mm
    puts table_mm
    puts '///'
    puts table_raw_source
    [
      {
        report_type: 'report_for_mm',
        table: table_mm.to_json
      },
      {
        report_type: 'report_by_raw_source',
        table: table_raw_source.to_json
      }
    ]
  end
end

FirstObjects.account_type.each { |obj| AccountType.create!(obj)}
FirstObjects.account.each { |obj| Account.create!(obj) }
FirstObjects.frequency.each { |obj| Frequency.create!(obj) }
FirstObjects.data_set.each { |obj| DataSet.create!(obj) }
FirstObjects.status.each { |obj| Status.create!(obj) }
FirstObjects.story_type.each { |obj| StoryType.create!(obj) }
FirstObjects.review.each { |obj| Review.create!(obj) }

ClientsPublicationsTagsJob.perform_now
ClientsTagsJob.perform_now
SectionsJob.perform_now
PhotoBucketsJob.perform_now
SlackAccountsJob.perform_now
# ReportForMmJob.perform_now
# ReportByRawSourceJob.perform_now

# daily
date = Date.new(2015, 1, 1)
end_date = Date.new(2025, 1, 1)
date_range = (date..end_date)
date_range.each { |dt| TimeFrame.create!(frame: "d:#{dt.yday}:#{dt.year}") }

# # weekly
# date = Date.new(2015, 1, 1)
# end_date = Date.new(2025, 1, 1)
# loop do
#   TimeFrame.create!(frame: "w:#{date.cweek}:#{date.year}")
#   date += 7
#   break if date > end_date
# end
#
# # monthly
# date = Date.new(2015, 1, 1)
# end_date = Date.new(2025, 1, 1)
# loop do
#   TimeFrame.create!(frame: "m:#{date.month}:#{date.year}")
#   date = date.next_month
#   break if date > end_date
# end
#
# # quarterly
# date = Date.new(2015, 1, 1)
# end_date = Date.new(2025, 1, 1)
# loop do
#   (1..4).each { |q| TimeFrame.create!(frame: "q:#{q}:#{date.year}") }
#   date = date >> 3
#   break if date > end_date
# end
#
# # biannually
# date = Date.new(2015, 1, 1)
# end_date = Date.new(2025, 1, 1)
# loop do
#   (1..2).each { |b| TimeFrame.create!(frame: "b:#{b}:#{date.year}") }
#   date = date >> 6
#   break if date > end_date
# end
#
# # annually
# date = Date.new(2015, 1, 1)
# end_date = Date.new(2025, 1, 1)
# loop do
#   TimeFrame.create!(frame: date.year)
#   date = date.next_year
#   break if date > end_date
# end
