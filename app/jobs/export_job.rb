# frozen_string_literal: true

class ExportJob < ApplicationJob
  queue_as :export

  def perform(story_type)
    status = true
    iteration = story_type.iteration
    message = Samples[PL_TARGET].export!(story_type)

    exp_st = ExportedStoryType.find_or_initialize_by(iteration: iteration)
    exp_st.developer = story_type.developer
    exp_st.first_export = story_type.iteration.name.eql?('Initial')
    exp_st.count_samples = story_type.iteration.samples.count

    if exp_st.new_record?
      story_type.update(last_export: Date.today)

      exp_st.week = Week.where(begin: Date.today - (Date.today.wday - 1)).first
      exp_st.date_export = Date.today
    end

    exp_st.save

  rescue StandardError => e
    message = e.message
  ensure
    story_type.update_iteration(export: status)

    send_to_action_cable(story_type, export_msg: status)
    send_to_slack(story_type, "export\n#{message}")
  end
end
