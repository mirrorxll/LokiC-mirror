# frozen_string_literal: true

module FactoidTypes
  class CodesController < FactoidTypesController # :nodoc:
    before_action :download_code, only: %i[attach reload]

    def show
      @ruby_code =
        CodeRay.scan(@factoid_type.code.download, :ruby).div(line_numbers: :table)
    end

    def attach
      render_403 && return if @factoid_type.code.attached? || @code.nil?

      @factoid_type.code.attach(io: StringIO.new(@code), filename: "A#{@factoid_type.id}.rb")
    end

    def reload
      render_403 && return if @code.nil?

      @factoid_type.code.purge
      @factoid_type.code.attach(io: StringIO.new(@code), filename: "A#{@factoid_type.id}.rb")
    end

    private

    def download_code
      # @code = @factoid_type.download_code_from_db
      @code = <<~CODE
        class F8
          STAGING_TABLE = 'f0008'
  
          def population(options)
            host = Mysql2::Client.new(host: '127.0.0.1', username: 'sergeydev', password: 'ni260584mss', database: 'loki_story_creator_dev_up')
            arry = (1..5).to_a
            # copy objectable ids from Limpar DB
            limpar_ids = ['02394358-ccc3-4ce6-a4f6-847f23a5df66',
                          'd43676bd-6201-401f-b9b1-b5bae2a6feb5',
                          'cebfef7b-ce99-46cd-a9f4-2ffab40c5716',
                          '12887d56-7fc6-4e9c-94f9-3b07222e2eac',
                          'd6d2ff77-3eed-41f1-9d0a-f1087ab31d17']

            arry.zip(limpar_ids).each do |arr, limpar|
              raw                         = {}
              raw['a']                    = arr
              raw['limpar_id']            = limpar
              raw['limpar_year']          = 2022
  
              staging_insert_query = SQL.insert_on_duplicate_key(STAGING_TABLE, raw, host)
              host.query(staging_insert_query)
            end
            host.close
            ArticleTypePopulationSuccess[STAGING_TABLE]
          end
  
          def creation(options)
            articles = Articles.new(STAGING_TABLE, options)
  
            StagingRecords[STAGING_TABLE, options].each do |stage|
              article = {}
              article[:staging_row_id]   = stage[:id]
  
              article[:body] = stage[:a]
              articles.insert(article)
            end
          end
        end
      CODE
    end
  end
end
