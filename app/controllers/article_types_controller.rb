# frozen_string_literal: true

class ArticleTypesController < ApplicationController
  skip_before_action :set_story_type_iteration
  skip_before_action :find_parent_story_type
  skip_before_action :find_parent_article_type, except: :properties_form
  skip_before_action :set_article_type_iteration

  before_action :redirect_scrapers,          only: :index
  before_action :find_data_set,              only: %i[new create]
  before_action :find_article_type,          except: %i[index new create properties_form]
  before_action :set_article_type_iteration, except: %i[index new create properties_form change_data_set]
  before_action :message,                    only: :update_sections
  before_action :find_current_data_set,      only: :change_data_set

  def index
    @grid_params = if request.parameters[:article_types_grid]
                     request.parameters[:article_types_grid]
                   else
                     developer? ? { order: :id, descending: true, developer: current_account.id } : { order: :id, descending: true }
                   end

    @article_types_grid = ArticleTypesGrid.new(@grid_params)

    respond_to do |f|
      f.html do
        @article_types_grid.scope { |scope| scope.page(params[:page]).per(50) }
      end

      f.csv do
        send_data(
          @article_types_grid.to_csv,
          type: 'text/csv',
          disposition: 'inline',
          filename: "lokic_article_types_#{Time.now}.csv"
        )
      end
    end
  end

  def show
    @tab_title = "LokiC::##{@article_type.id} #{@article_type.name}"
  end

  def new; end

  def create
    @article_type = @data_set.article_types.build(new_article_type_params)

    if @article_type.save!
      redirect_to data_set_path(@data_set)
    else
      render :new
    end
  end

  def edit; end

  def update
    @article_type.update!(exist_article_type_params)
  end

  def properties_form; end

  def change_data_set
    @article_type.update!(change_data_set_params)
  end

  def update_sections; end

  private

  def redirect_scrapers
    redirect_to scrape_tasks_path if only_scraper?
  end

  def check_access
    redirect_to root_path
  end

  def find_data_set
    @data_set = DataSet.find(params[:data_set_id])
  end

  def find_article_type
    @article_type = ArticleType.find(params[:id])
  end

  def new_article_type_params
    permitted = params.require(:article_type).permit(:name)

    {
      name: permitted[:name],
      status: Status.find_by(name: 'not started'),
      editor: current_account,
      current_account: current_account
    }
  end
  def exist_article_type_params
    attrs = params.require(:article_type).permit(:name,
                                                 :topic_kind,
                                                 :source_type,
                                                 :source_name,
                                                 :source_link,
                                                 :original_publish_date)
    attrs[:current_account] = current_account
    attrs
  end

  def filter_params
    return {} unless params[:filter]

    params.require(:filter).slice(:data_set, :developer, :frequency, :status)
  end

  def change_data_set_params
    attrs = params.require(:article_type).permit(:data_set_id)
    attrs[:current_account] = current_account
    attrs
  end

  def find_current_data_set
    @current_data_set = DataSet.find(params[:current_data_set_page_id])
  end

  def message
    @key = params[:message][:key].to_sym
    flash.now[@key] = params[:message][@key]
  end
end
