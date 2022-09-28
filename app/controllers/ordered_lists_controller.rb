# frozen_string_literal: true

class OrderedListsController < ApplicationController
  def update
    lists = current_account.ordered_lists.where(branch_name: subject)
    positions.each do |k, v|
      grid = lists.find_by(grid_name: k)
      grid.update(position: v)
    end
    statuses      = Status.scrape_task_statuses(created: true, done: true)
    allowed_grids = current_account.ordered_lists.where(branch_name: 'scrape_tasks').order(:position)
    @lists        = HashWithIndifferentAccess.new

    allowed_grids.each do |grid|
      @lists[grid.grid_name] = { status: statuses }

      @lists[grid.grid_name].merge!(creator: current_account) if grid.grid_name.eql?('created')
      @lists[grid.grid_name].merge!(scraper: current_account) if grid.grid_name.eql?('assigned')
      @lists[grid.grid_name].merge!(status: Status.find_by(name: 'archived')) if grid.grid_name.eql?('archived')
    end
    keys = @lists.keys

    @current_list =
      if current_list && keys.include?(current_list)
        current_list
      else
        first_grid = current_account.ordered_lists.first_grid('scrape_tasks')
        (current_account.manager? || current_account.scrape_manager?) && @lists['all'] ? 'all' : @current_list = first_grid
      end
  end

  private

  def subject
    params.require(:subject)
  end

  def positions
    params.require(:data).permit!
  end

  def current_list
    params[:current_list].present? ? params.require(:current_list) : nil
  end
end
