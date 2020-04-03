# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

class FirstObjects # :nodoc:
  def self.account_type
    [
      {
        name: 'super-user',
        permissions: {
          other_user: {
            read: true,
            create: true,
            update: true,
            delete: true
          },
          data_set: {
            read: true,
            create: true,
            update: true,
            delete: true
          },
          story_type: {
            create: true,
            delete: true,
            distribution: {
              read: true,
              update: true
            },
            dev_status: {
              read: true,
              update: true
            },
            template: {
              read: true,
              update: true
            },
            configuration: {
              read: true,
              update: true
            },
            staging_table: {
              read: true,
              update: true
            },
            code: {
              read: true,
              update: true
            },
            sample: {
              read: true,
              update: true
            },
            schedule: {
              read: true,
              update: true
            },
            export: {
              read: true,
              update: true
            }
          }
        }
      },
      {
        name: 'manager',
        permissions: {
          other_user: {
            read: true,
            create: true
          },
          data_set: {
            read: true,
            create: true,
            update: true
          },
          story_type: {
            create: true,
            distribution: {
              read: true,
              update: true
            },
            dev_status: {
              read: true,
              update: true
            },
            template: {
              read: true,
              update: true
            },
            configuration: {
              read: true,
              update: true
            },
            staging_table: {
              read: true,
              update: true
            },
            code: {
              read: true,
              update: true
            },
            sample: {
              read: true,
              update: true
            },
            schedule: {
              read: true,
              update: true
            },
            export: {
              read: true,
              update: true
            }
          }
        }
      },
      {
        name: 'editor',
        permissions: {
          other_user: {},
          data_set: {
            read: true
          },
          story_type: {
            create: true,
            delete: true,
            distribution: {
              read: true,
              update: true
            },
            dev_status: {},
            template: {
              read: true,
              update: true
            },
            configuration: {
              read: true,
              update: true
            },
            staging_table: {},
            code: {},
            sample: {},
            schedule: {},
            export: {}
          }
        }
      },
      {
        name: 'developer',
        permissions: {
          other_user: {},
          data_set: {},
          story_type: {
            distribution: {},
            dev_status: {
              read: true,
              update: true
            },
            template: {
              read: true,
              update: true
            },
            configuration: {
              read: true
            },
            staging_table: {
              read: true,
              update: true
            },
            code: {
              read: true,
              update: true
            },
            sample: {
              read: true,
              update: true
            },
            schedule: {
              read: true,
              update: true
            },
            export: {
              read: true,
              update: true
            }
          }
        }
      }
    ]
  end

  def self.user
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
      }
    ]
  end

  def self.data_set
    [
      {
        source_name: 'Gas Buddy',
        data_set_location: 'db12.usa_raw.gasbuddy_%',
        data_set_evaluation_document: 'http://',
        evaluated: true,
        scrape_developer_name: 'Vlad Sviridov',
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
        evaluated: false,
        scrape_developer_name: 'Vlad Sviridov',
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

  def self.story_type
    [
      {
        name: 'Story Type 1',
        editor: User.first,
        data_set: DataSet.first
      },
      {
        name: 'Story Type 2',
        editor: User.first,
        developer: User.first,
        data_set: DataSet.last
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

  def self.publication
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

  def self.frequency
    %w[Weekly Monthly Quarterly Semi-Annually Annually Biennial].map do |item|
      { name: item }
    end
  end
end

FirstObjects.account_type.each { |obj| AccountType.create!(obj)}
FirstObjects.user.each { |obj| User.create!(obj) }
FirstObjects.data_set.each { |obj| DataSet.create!(obj) }
FirstObjects.story_type.each { |obj| StoryType.create!(obj) }
FirstObjects.client.each { |obj| Client.create!(obj) }
FirstObjects.publication.each { |obj| Publication.create!(obj) }
FirstObjects.section.each { |obj| Section.create!(obj) }
FirstObjects.tag.each { |obj| Tag.create!(obj) }
FirstObjects.photo_bucket.each { |obj| PhotoBucket.create!(obj) }
FirstObjects.frequency.each { |obj| Frequency.create!(obj) }
