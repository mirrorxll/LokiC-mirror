# frozen_string_literal: true

module Api
  class PublicationsController < ApiController
    def index
      publications = Client.find(params[:client_id]).publications.select(:id, :name).order(:name)

      render json: publications
    end

    def scopes
      names = ['all local publications', 'all publications', 'all statewide publications']
      raw_sql = Arel.sql("FIELD(name, '#{names.join("', '")}')")
      scopes = Publication.select(:id, :name).where(name: names).order(raw_sql)

      render json: scopes
    end

    def all_pubs_scope_id
      id = Publication.find_by(name: 'all publications').id

      render json: id
    end

    def all_local_pubs_scope_id
      id = Publication.find_by(name: 'all local publications').id

      render json: id
    end

    def all_statewide_pubs_scope_id
      id = Publication.find_by(name: 'all statewide publications').id

      render json: id
    end
  end
end
