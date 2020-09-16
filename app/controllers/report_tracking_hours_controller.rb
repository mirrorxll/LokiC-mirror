# frozen_string_literal: true

class ReportTrackingHoursController < ApplicationController # :nodoc:
  skip_before_action :find_parent_story_type

  def index
    @rows_reports = ReportTrackingHour.all.where(account: current_account)
  end

  def create

  end

  def update

  end

  def destroy

  end

end
