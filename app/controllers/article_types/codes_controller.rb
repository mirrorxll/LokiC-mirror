# frozen_string_literal: true

module ArticleTypes
  class CodesController < ApplicationController # :nodoc:
    skip_before_action :find_parent_story_type
    skip_before_action :set_story_type_iteration
    skip_before_action :set_article_type_iteration

    before_action :render_403, if: :editor?
    before_action :download_code, only: %i[attach reload]

    def show
      @ruby_code =
        CodeRay.scan(@article_type.code.download, :ruby).div(line_numbers: :table)
    end

    def attach
      render_403 && return if @article_type.code.attached? || @code.nil?

      @article_type.code.attach(io: StringIO.new(@code), filename: "A#{@article_type.id}.rb")
    end

    def reload
      render_403 && return if @code.nil?

      @article_type.code.purge
      @article_type.code.attach(io: StringIO.new(@code), filename: "A#{@article_type.id}.rb")
    end

    private

    def download_code
      # @code = @article_type.download_code_from_db
      @code = <<~CODE
        class A8
          STAGING_TABLE = 'a0008'
        
          def population(options)
            host = Mysql2::Client.new(host: '127.0.0.1', username: 'sergeydev', password: 'ni260584mss', database: 'loki_story_creator_dev')
            arry = (1..3).to_a
            arry.each do |arr|
              raw                         = {}
              raw['a']                    = arr
              raw['limpar_id']            = 'f57857ec-8fba-4f54-9398-94b26c8217eb'
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
