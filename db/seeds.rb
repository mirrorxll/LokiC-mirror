# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

class FirstObjects # :nodoc:
  class << self
    def account_type
      [
        {
          name: 'super-user',
          permissions: {
            other_account: {
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
            other_account: {
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
            other_account: {},
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
            other_account: {},
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

          scrape_developer: 'Vlad Sviridov',
          comment: 'bla bla bla',
          gather_task: 'https://gather.task'
        }
      ]
    end

    def status
      [
        { name: 'not started' },
        { name: 'in progress' },
        { name: 'exported' },
        { name: 'on cron' },
        { name: 'blocked' }
      ]
    end

    def story_type
      [
        {
          name: 'Story Type 1',
          editor: Account.first,
          data_set: DataSet.first,
          status: Status.first
        },
        {
          name: 'Story Type 2',
          editor: Account.first,
          developer: Account.first,
          data_set: DataSet.last,
          status: Status.first
        }
      ]
    end

    def client
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

    def publication
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

    def section
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

    def tag
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

    def photo_bucket
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

    def frequency
      ['daily', 'weekly', 'monthly', 'quarterly',
       'annually', 'manual input'].map { |item| { name: item } }
    end
  end
end

FirstObjects.account_type.each { |obj| AccountType.create!(obj)}
FirstObjects.account.each { |obj| Account.create!(obj) }
FirstObjects.data_set.each { |obj| DataSet.create!(obj) }
FirstObjects.status.each { |obj| Status.create!(obj) }
FirstObjects.story_type.each { |obj| StoryType.create!(obj) }
FirstObjects.client.each { |obj| Client.create!(obj) }
FirstObjects.publication.each { |obj| Publication.create!(obj) }
FirstObjects.section.each { |obj| Section.create!(obj) }
FirstObjects.tag.each { |obj| Tag.create!(obj) }
FirstObjects.photo_bucket.each { |obj| PhotoBucket.create!(obj) }
FirstObjects.frequency.each { |obj| Frequency.create!(obj) }
