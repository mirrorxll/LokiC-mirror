# frozen_string_literal: true

class ExportJob < ApplicationJob
  queue_as :export

  def perform(story_type)
    status = true
    message = 'SUCCESS. MAKE SURE THAT ALL STORIES ARE EXPORTED'
    iteration = story_type.iteration
    threads_count = (iteration.samples.count / 75_000.0).ceil + 1
    exception = nil

    iteration.update(last_export_batch_size: nil)

    loop do
      rd, wr = IO.pipe

      Process.wait(
        fork do
          rd.close
          Samples[PL_TARGET].export!(iteration, threads_count)
        rescue StandardError => e
          wr.write %({"#{e.class}":"#{e.message}"})
        ensure
          wr.close
        end
      )

      wr.close
      exception = rd.read
      rd.close

      last_export_batch = iteration.reload.last_export_batch_size&.zero?
      break if last_export_batch || exception.present?
    end

    if exception.present?
      klass, message = JSON.parse(exception).to_a.first
      raise Object.const_get(klass), message
    end

    Process.wait(
      fork do
        exp_st = ExportedStoryType.find_or_initialize_by(iteration: iteration)
        exp_st.developer = story_type.developer
        exp_st.first_export = iteration.name.eql?('Initial')
        exp_st.count_samples = iteration.samples.count

        if exp_st.new_record?
          story_type.update(last_export: Date.today)

          exp_st.week = Week.where(begin: Date.today - (Date.today.wday - 1)).first
          exp_st.date_export = Date.today
        end

        exp_st.save
      end
    )
  rescue StandardError => e
    message = e.message
  ensure
    iteration.reload.update(export: status)

    send_to_action_cable(story_type, iteration, export_msg: status)
    send_to_slack(story_type, 'export', message)
  end
end
