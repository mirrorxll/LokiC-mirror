# frozen_string_literal: true

class TasksController < ApplicationController # :nodoc:
  skip_before_action :find_parent_story_type
  skip_before_action :set_iteration

  def index
    @tasks = Task.all
  end

  def show

  end

  def create

  end

  def edit; end

  def update

  end

  def destroy

  end

end
