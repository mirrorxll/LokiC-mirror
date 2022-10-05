# frozen_string_literal: true

class OrderedListsController < ApplicationController
  def update
    lists = current_account.ordered_lists.where(branch_name: subject)
    positions.each do |k, v|
      grid = lists.find_by(grid_name: k)
      grid.update(position: v)
    end
    generate_grid_lists
    generate_current_list
  end

  private

  def generate_grid_lists
    statuses      = set_statuses
    allowed_grids = current_account.ordered_lists.where(branch_name: subject).order(:position)
    @lists        = HashWithIndifferentAccess.new
    @branch       = subject

    allowed_grids.each do |grid|
      @lists[grid.grid_name] = { status: statuses }

      @lists[grid.grid_name].merge!("#{created_list_account}": current_account)  if grid.grid_name.eql?('created')
      @lists[grid.grid_name].merge!("#{assigned_list_account}": current_account) if grid.grid_name.eql?('assigned')
      @lists[grid.grid_name].merge!(responsible_editor: current_account)         if grid.grid_name.eql?('responsible')
      @lists[grid.grid_name].merge!(status: Status.find_by(name: 'archived'))    if grid.grid_name.eql?('archived')
    end
  end

  def generate_current_list
    keys = @lists.keys
    @current_list =
      if current_list && keys.include?(current_list)
        current_list
      else
        first_grid = current_account.ordered_lists.first_grid(subject)
        (current_account.manager? || second_manager) && @lists['all'] ? 'all' : @current_list = first_grid
      end
  end

  def set_statuses
    case subject
    when 'data_sets'
      Status.data_set_statuses
    when 'factoid_requests'
      Status.factoid_request_statuses(created: true)
    when 'factoid_types', 'story_types'
      Status.hle_statuses(created: true, migrated: true, inactive: true)
    when 'multi_tasks'
      Status.multi_task_statuses(created: true)
    when 'scrape_tasks'
      Status.scrape_task_statuses(created: true, done: true)
    when 'work_requests'
      Status.work_request_statuses(created: true)
    end
  end

  def created_list_account
    case subject
    when 'data_sets'
      'account'
    when 'factoid_requests', 'work_requests'
      'requester'
    when 'factoid_types', 'story_types'
      'editor'
    when 'multi_tasks', 'scrape_tasks'
      'creator'
    end
  end

  def assigned_list_account
    case subject
    when 'data_sets'
      'sheriff'
    when 'factoid_types', 'story_types'
      'developer'
    when 'multi_tasks'
      'multi_task_assignments.account_id'
    when 'scrape_tasks'
      'scraper'
    end
  end

  def second_manager
    case subject
    when 'data_sets', 'factoid_types', 'story_types'
      current_account.content_manager?
    when 'multi_tasks'
      current_account.multi_tasks_manager?
    when 'scrape_tasks'
      current_account.scrape_manager?
    end
  end

  def subject
    params[:subject].presence
  end

  def positions
    params.require(:data).permit!
  end

  def current_list
    params[:current_list].presence
  end
end
