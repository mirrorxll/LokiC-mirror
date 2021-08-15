# frozen_string_literal: true

module ArticleTypes
  class StagingTablesController < ApplicationController # :nodoc:
    skip_before_action :find_parent_story_type
    skip_before_action :set_story_type_iteration

    before_action :render_403, if: :editor?
    before_action :staging_table_name_from_params, only: :create
    before_action :staging_table

    def create
      flash.now[:error] =
        if @staging_table.present?
          @article_type.update!(staging_table_attached: true, current_account: current_account)
          'Table for this article type already exist. Please update the page.'
        elsif StagingTable.find_by(name: @staging_table_name)
          "Table with name '#{@staging_table_name}' already attached to another article type."
        elsif @staging_table_name.present? && StagingTable.not_exists?(@staging_table_name)
          "Table with name '#{@staging_table_name}' not exists."
        else
          StagingTableAttachingJob.perform_later(@article_type, current_account, @staging_table_name)
          @article_type.update!(staging_table_attached: false, current_account: current_account)
          nil
        end

      render 'show'
    end

    def detach
      staging_table_action do
        messages = @staging_table.destroy.errors.full_messages
        @article_type.update!(staging_table_attached: nil, current_account: current_account)
        messages.any? ? messages.join(' | ') : nil
      end

      render 'new'
    end

    def sync
      staging_table_action { @staging_table.sync }

      render 'show'
    end

    def canceling_edit
      render 'show'
    end

    private

    def staging_table_name_from_params
      @staging_table_name = params.require(:staging_table).permit(:name)[:name]
    end

    def staging_table
      @staging_table = @article_type.staging_table
    end
  end
end
