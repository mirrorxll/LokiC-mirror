# frozen_string_literal: true

class FirstObjects # :nodoc:
  def self.story
    [
      {
        name: 'Story Type 1',
        headline: 'Some Headline',
        body: 'Some Body',
        description: 'Some Description',
        writer: User.first
      },
      {
        name: 'Story Type 2',
        headline: 'Some Headline',
        body: 'Some Body',
        description: 'Some Description',
        writer: User.first
      }
    ]
  end

  def self.data_location
    [
      {
        name: 'Gas Buddy',
        source: 'https://www.gasbuddy.com/',
        dataset: 'db12.usa_raw.gasbuddy_%',
        note: 'updated every 2 days'
      },
      {
        name: 'US Department of Agriculture ',
        source: 'https://www.fns.usda.gov/pd/supplemental-nutrition-assistance-program-snap',
        dataset: 'db12.usa_raw.usda_%',
        note: ''
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
