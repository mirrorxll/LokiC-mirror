# frozen_string_literal: true

class ExportJob < ApplicationJob
  queue_as :story_type

  def perform(iteration)
    status = true
    message = 'Success. Make sure that all stories are exported'
    threads_count = (iteration.samples.count / 75_000.0).ceil + 1

    iteration.update(last_export_batch_size: nil)

    loop do
      rd, wr = IO.pipe

      Process.wait(
        fork do
          rd.close
          Samples[PL_TARGET].export!(iteration, threads_count)
        rescue StandardError => e
          wr.write({ e.class.to_s => e.message }.to_json)
        ensure
          wr.close
        end
      )

      wr.close
      exception = rd.read
      rd.close

      if exception.present?
        klass, message = JSON.parse(exception).to_a.first
        raise Object.const_get(klass), message
      end

      last_export_batch = iteration.reload.last_export_batch_size&.zero?
      break if last_export_batch
    end

    Process.wait(
      fork do
        exp_st = ExportedStoryType.find_or_initialize_by(iteration: iteration)
        exp_st.developer = iteration.story_type.developer
        exp_st.first_export = iteration.name.eql?('Initial')
        exp_st.count_samples = iteration.samples.count

        if exp_st.new_record?
          iteration.story_type.update(last_export: Date.today)

          exp_st.week = Week.where(begin: Date.today - (Date.today.wday - 1)).first
          exp_st.date_export = Date.today
        end

        exp_st.save
      end
    )
  rescue StandardError => e
    status = nil
    message = e.message
  ensure
    iteration.reload.update(export: status)
    send_to_action_cable(iteration, :export, message)
    send_to_slack(iteration, 'EXPORT', message)
    iteration.export
  end
end
