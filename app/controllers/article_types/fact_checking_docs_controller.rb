# frozen_string_literal: true

module ArticleTypes
  class FactCheckingDocsController < ApplicationController
    skip_before_action :find_parent_story_type
    skip_before_action :set_story_type_iteration

    before_action :find_fcd, except: :template

    def show
      @tab_title = "LokiC :: FactoidType ##{@article_type.id} :: FCD"
    end

    def edit; end

    def save
      @fcd.update!(fcd_params)
    end

    def update
      @fcd.update!(fcd_params)

      if @fcd.errors.any?
        render :edit
      else
        redirect_to article_type_fact_checking_doc_path(@article_type, @fcd)
      end
    end

    def template
      @template = @article_type.template

      respond_to do |format|
        format.js { render 'template' }
        format.html { redirect_to article_type_template_path(@article_type, @template) }
      end
    end

    def send_to_reviewers_channel
      response = ::SlackNotificationJob.new.perform('hle_reviews_queue', message_to_slack)
      @fcd.update!(slack_message_ts: response[:ts])
    end

    private

    def find_fcd
      @fcd = @article_type.fact_checking_doc
    end

    def fcd_params
      params.require(:fact_checking_doc).permit(:body)
    end

    def send_to_reviewers_params
      params.require(:slack_message).permit(:channel, :note)
    end

    def message_to_slack
      info = send_to_reviewers_params

      "*Factoid Type FCD* ##{@article_type.id} <#{article_type_fact_checking_doc_url(@article_type, @fcd)}|#{@article_type.name}>.\n"\
      "*Developer:* #{@article_type.developer.name}.\n"\
      "#{info[:note].present? ? "*Note*: #{info[:note]}" : ''}"
    end
  end
end
