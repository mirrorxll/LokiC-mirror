# frozen_string_literal: true

class FirstObjects # :nodoc:
  def self.story_type
    [
      {
        name: 'Story Type 1',
        body: 'Some Body',
        description: 'Some Description',
        editor: User.first,
        data_location: DataLocation.first
      },
      {
        name: 'Story Type 2',
        body: 'Some Body',
        description: 'Some Description',
        editor: User.first,
        developer: User.first,
        data_location: DataLocation.last
      }
    ]
  end

  def self.data_location
    [
      {
        source_name: 'Gas Buddy',
        data_set_location: 'db12.usa_raw.gasbuddy_%',
        data_set_evaluation_document: 'http://',
        scrape_dev_developer_name: 'Vlad Sviridov',
        scrape_source: 'https://www.gasbuddy.com/',
        scrape_frequency: 'daily',
        data_release_frequency: 'daily',
        cron_scraping: true,
        scrape_developer_comments: 'bla bla bla',
        source_key_explaining_data: 'https://..',
        gather_task: 'https://',
        user: User.first
      },
      {
        source_name: 'US Department of Agriculture',
        data_set_location: 'db12.usa_raw.usda_%',
        data_set_evaluation_document: nil,
        scrape_dev_developer_name: 'Vlad Sviridov',
        scrape_source: 'https://www.fns.usda.gov/pd/supplemental-nutrition-assistance-program-snap',
        scrape_frequency: 'annually',
        data_release_frequency: 'quarterly',
        cron_scraping: false,
        scrape_developer_comments: 'bla bla bla',
        source_key_explaining_data: 'https://..',
        gather_task: 'https://',
        user: User.first
      }
    ]
  end

  def self.section
    [
      {
        pipeline_index: 16,
        name: 'HLE Content'
      },
      {
        pipeline_index: 'Latest',
        name: 'Latest'
      }
    ]
  end

  def self.tag
    [
      {
        pipeline_index: 3,
        name: 'Public Policy'
      },
      {
        pipeline_index: 4,
        name: 'Top News'
      }
    ]
  end

  def self.photo_bucket
    [
      {
        pipeline_index: 136,
        name: 'Military',
        minimum_height: 667,
        minimum_width: 1000,
        aspect_ratio: '1000:667'
      },
      {
        pipeline_index: 26,
        name: 'Cargo Ship',
        minimum_height: 640,
        minimum_width: 1280,
        aspect_ratio: '2:1'
      }
    ]
  end

  def self.client
    [
      {
        pipeline_index: 120,
        name: 'Metro Business'
      },
      {
        pipeline_index: 200,
        name: 'MM - Idaho'
      }
    ]
  end

  def self.project
    [
      {
        pipeline_index: 655,
        name: 'Keystone Business News',
        client: Client.first
      },
      {
        pipeline_index: 2675,
        name: 'Ada Reporter',
        client: Client.last
      }
    ]
  end

  def self.level
    %w[Zip City County State USA].map { |item| { name: item } }
  end

  def self.frequency
    %w[Weekly Monthly Quarterly Semi-Annually Annually Biennial].map do |item|
      { name: item }
    end
  end
end
