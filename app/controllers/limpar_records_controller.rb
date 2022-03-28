class LimparRecordsController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :find_parent_article_type
  skip_before_action :set_story_type_iteration
  skip_before_action :set_article_type_iteration

  def get_limpar_data
    case params[:kind]
    when 'Person'
      @records = LimparPeople.first(100)
    when 'Organization'
      @records = LimparOrganization.first(100)
    when 'Geo'
      @records = LimparState.all.pluck(:id, :name)
    end
  end
end