# frozen_string_literal: true

module FactoidTypes
  class CodesController < FactoidTypesController # :nodoc:
    skip_before_action :set_factoid_type_iteration

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
        class A1
          STAGING_TABLE = 'a0001'
  
          def population(options)
            host = Mysql2::Client.new(host: '127.0.0.1', username: 'sergeydev', password: 'ni260584mss', database: 'loki_story_creator_dev')
            arry = (1..5).to_a
            # copy objectable ids from Limpar DB
            limpar_ids = ['678cc815-74f2-4f42-a761-e58fd11f6dfa',
                          '24f7e0c7-6864-4fa5-9c7d-678be879d0f5',
                          '92694c2d-e1a0-4ead-a512-dcca0ce73ff0',
                          '0269a0e5-a120-4336-a557-d587aca3f6a8',
                          '6b6a6fe7-7893-401d-be20-ce90fcb010b8'
            ]
            arry.each do |arr|
              raw                         = {}
              raw['a']                    = arr
              raw['limpar_id']            = limpar_ids.sample
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
