# frozen_string_literal: true

module StoryTypes
  class CodesController < ApplicationController # :nodoc:
    skip_before_action :find_parent_article_type
    skip_before_action :set_article_type_iteration
    skip_before_action :set_story_type_iteration, only: :show

    before_action :render_403, if: :editor?
    before_action :download_code, only: %i[attach reload]

    def show
      @ruby_code =
        CodeRay.scan(@story_type.code.download, :ruby).div(line_numbers: :table)
    end

    def attach
      render_403 && return if @story_type.code.attached? || @code.nil?

      @story_type.code.attach(io: StringIO.new(@code), filename: "S#{@story_type.id}.rb")
    end

    def reload
      render_403 && return if @code.nil?

      @story_type.code.purge
      @story_type.code.attach(io: StringIO.new(@code), filename: "S#{@story_type.id}.rb")
    end

    private

    def download_code
      # @code = @story_type.download_code_from_db
      @code = <<~CODE
        class S1
          STAGING_TABLE = 's0001'
          def check_updates; end
          def population(options)
            host = Mysql2::Client.new(host: '127.0.0.1', username: 'sammy', password: 'passworD=123', database: 'loki_story_creator_dev')
            raw                     = {}
            raw['client_id']        = 196
            raw['client_name']      = "MM - New York"
            raw['publication_id']   = 2813
            raw['publication_name'] = 'NYC Gazette'
            raw['organization_ids'] = 645397327
            raw['time_frame']       = Frame[:annually, Date.today.to_s]
    
            raw['a']                = 'year'
            staging_insert_query = SQL.insert_on_duplicate_key(STAGING_TABLE, raw)
            host.query(staging_insert_query)
            host.close
            PopulationSuccess[STAGING_TABLE] unless ENV['RAILS_ENV']
          end
          def creation(options)
            samples = Samples.new(STAGING_TABLE, options)
            StagingRecords[STAGING_TABLE, options].each do |stage|
              pp "> "*50, stage
              sample                    = {}
              sample[:staging_row_id]   = stage['id']
              sample[:publication_id]   = 2813
              sample[:organization_ids] = 645397327
              sample[:time_frame]       = '2022'
              foo                       = stage['a']
        
              sample[:headline] = 'headline'
              sample[:teaser]   = 'teaser'
              sample[:body]     = foo
        
              samples.insert(sample)
            end
          end
        end
      CODE
    end
  end
end
