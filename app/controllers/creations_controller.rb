# frozen_string_literal: true

class CreationsController < ApplicationController # :nodoc:
  def execute
    @story.staging_table.execute_creation
  end

  def purge
    @story.staging_table.purge_last_creation
  end
end
