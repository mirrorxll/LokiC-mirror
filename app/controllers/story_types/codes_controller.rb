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
        class S3
          STAGING_TABLE = 's0003'
          def check_updates; end
          def population(options)
            host = Mysql2::Client.new(host: '127.0.0.1', username: 'sergeydev', password: 'ni260584mss', database: 'loki_story_creator_dev')
            arry = ('a'..'z').to_a
            arry.each do |arr|
              publications = [{ 'id' => 2813, 'name' => 'NYC Gazette', 'client_id' => 196, 'client_name' => 'MM - New York' }]
              publications.flatten.each do |publication|
                raw                      = {}
                raw['client_id']         = publication['client_id']
                raw['client_name']       = publication['client_name']
                raw['publication_id']    = publication['id']
                raw['publication_name']  = publication['name']
                raw['organization_ids']  = 645_397_327
                raw['time_frame']        = Frame[:annually, Date.today.to_s]
            
                raw['b']                 = arr * 15
                return if SidekiqBreak[self.class.to_s]
                
                staging_insert_query = SQL.insert_on_duplicate_key(STAGING_TABLE, raw)
                host.query(staging_insert_query)
              end
            end
            host.close
            PopulationSuccess[STAGING_TABLE] unless ENV['RAILS_ENV']
          end
          def creation(options)
            samples = Samples.new(STAGING_TABLE, options)
            StagingRecords[STAGING_TABLE, options].each do |stage|
              sample                    = {}
              sample[:staging_row_id]   = stage['id']
              sample[:publication_id]   = stage['publication_id']
              sample[:organization_ids] = stage['organization_ids']
              sample[:time_frame]       = stage['time_frame']
              foo                       = stage['b']
        
              sample[:headline] = foo
              sample[:teaser]   = 'teaser'
              sample[:body]     = stage['a']
        
              return if SidekiqBreak[self.class.to_s]

              samples.insert(sample)
            end
          end
        end
      CODE
    end
  end
end
