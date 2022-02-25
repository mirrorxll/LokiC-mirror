# frozen_string_literal: true

class PressReleaseReportsGrid
  include Datagrid

  # def initialize(*args, &block)
  #   @press_release = Reports::PressReleaseReport.new.stories
  # end

  scope do
    Reports::PressReleaseReport.new.stories
  end

  column(:prr_type, mandatory: true) do |pr_r|
    puts pr_r
    puts pr_r['prr_type']
    pr_r['prr_type']
  end

  column(:client_id, mandatory: true) do |pr_r|
    pr_r['client_id']
  end

  column(:client_name, mandatory: true) do |pr_r|
    pr_r['client_name']
  end

  column(:publication_id, mandatory: true) do |pr_r|
    pr_r['publication_id']
  end

  column(:publication_name, mandatory: true) do |pr_r|
    pr_r['publication_name']
  end

  column(:story_date, mandatory: true) do |pr_r|
    pr_r['story_date']
  end

  column(:story_week, mandatory: true) do |pr_r|
    pr_r['story_week']
  end

  column(:count_story_id, mandatory: true) do |pr_r|
    pr_r['count_story_id']
  end
end