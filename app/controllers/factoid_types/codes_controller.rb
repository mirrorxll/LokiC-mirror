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
            limpar_ids = ['92d5c7c8-4c19-4c5f-9a81-f605d42dd921',
                          'f617c7e9-0cdb-401e-9349-c605f290a8d2',
                          '97ea1729-fceb-4d08-9b23-082caa764571',
                          'da597971-755c-4f00-96b8-de5df42a49e1',
                          '03feec45-1814-487f-8243-3f963e35c347']

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
