# frozen_string_literal: true

class DataSetsController < ApplicationController # :nodoc:
  before_action -> { authorize!('data_sets') }
  before_action -> { authorize!('story_types', redirect: false) }
  before_action -> { authorize!('factoid_types', redirect: false) }

  private

  def find_data_set
    @data_set = DataSet.find(params[:data_set_id] || params[:id])
  end

  def find_status_comment
    @status_comment = @data_set.status_comment || @data_set.create_status_comment
  end
end
