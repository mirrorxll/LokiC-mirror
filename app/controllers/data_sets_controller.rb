# frozen_string_literal: true

class DataSetsController < ApplicationController # :nodoc:
  before_action -> { authorize!('data_sets') }

  before_action :find_data_set, except: %i[index create]

  private

  def find_data_set
    @data_set = DataSet.find(params[:id] || params[:id])
  end
end
