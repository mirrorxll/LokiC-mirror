# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_account!
  before_action :find_parent_story_type
  before_action :set_iteration
  impersonates :account

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit :sign_in, keys: %i[email password remember_me]
    devise_parameter_sanitizer.permit :account_update, keys: %i[email first_name last_name password password_confirmation current_password]
  end

  def find_parent_story_type
    @story_type = StoryType.find(params[:story_type_id])
  end

  def set_iteration
    @iteration =
      if params[:iteration_id]
        Iteration.find(params[:iteration_id])
      else
        @story_type.iteration
      end
  end

  def manager?
    current_account.types.include?('manager')
  end

  def editor?
    current_account.types.include?('editor')
  end

  def developer?
    current_account.types.eql?(['developer'])
  end

  def scraper?
    current_account.types.eql?(['scraper'])
  end

  def only_scraper?
    acc_types = current_account.types
    acc_types.count.eql?(1) && acc_types.first.eql?('scraper')
  end

  def render_400
    render json: { error: 'Bad Request' }, status: 400
  end
  alias render_400_developer render_400
  alias render_400_editor    render_400

  def staging_table_action(&block)
    flash.now[:staging_table] =
      if @staging_table.nil? || StagingTable.not_exists?(@staging_table.name)
        @story_type.update(staging_table_attached: nil)
        @staging_table&.destroy
        detached_or_delete
      else
        block.call
      end
  rescue StandardError => e
    flash.now[:staging_table] = e.message
  end

  def detached_or_delete
    'The Table for this story type has been renamed, detached or drop. Please update the page.'
  end

  def record_to_change_history(story_type, event, message)
    note_to_md5 = Digest::MD5.hexdigest(message)
    note = Note.find_or_create_by!(md5hash: note_to_md5) { |t| t.note = message }
    history_event = HistoryEvent.find_or_create_by!(name: event)

    story_type.change_history.create!(history_event: history_event, note: note)
  end
end
