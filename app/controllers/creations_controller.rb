# frozen_string_literal: true

class CreationsController < ApplicationController # :nodoc:
  def execute
    @story.staging_table.execute_code('create', {})
  end

  def purge
    @story.staging_table.purge_last_creation
  end
end
