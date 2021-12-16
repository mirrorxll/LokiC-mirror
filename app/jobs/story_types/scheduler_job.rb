# frozen_string_literal: true

module StoryTypes
  class SchedulerJob < StoryTypesJob
    def perform(iteration, type, options = {})
      status = nil
      message = 'Success'
      story_type = iteration.story_type
      options[:account] ||= story_type.developer

      rd, wr = IO.pipe

      Process.wait(
        fork do
          rd.close
          samples = iteration.stories

          case type
          when :manual
            MiniLokiC::Creation::Scheduler::Base.run_schedule(samples, manual_params(options[:params]))
          when :backdate
            MiniLokiC::Creation::Scheduler::Backdate.backdate_scheduler(samples, backdate_params(options[:params]))
          when :auto
            MiniLokiC::Creation::Scheduler::Auto.run_auto(samples, auto_params(options[:params]))
          when :"run-from-code"
            MiniLokiC::Creation::Scheduler::FromCode.run_from_code(samples, options[:params])
          end

          record_to_change_history(story_type, 'scheduled', type, options[:account])
        rescue StandardError, ScriptError => e
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

      status = true if iteration.reload.stories.where(published_at: nil).none?

      counts = {}
      stories = iteration.stories

      if (counts[:total] = stories.count).zero?
        counts[:scheduled] = 0
        counts[:backdated] = 0
      else
        published = stories.where.not(published_at: nil)
        counts[:scheduled] = published.where(backdated: 0).count
        counts[:backdated] = published.count - counts[:scheduled]
      end

      current_schedule_counts = iteration.schedule_counts || {}

      iteration.update!(
        schedule_counts: current_schedule_counts.merge(counts),
        current_account: options[:account]
      )

      true
    rescue StandardError, ScriptError => e
      status = nil
      message = e.message

      raise SchedulerExecutionError, "Scheduling from code: #{message}" if options[:exception]
    ensure
      iteration.update!(schedule: status)

      unless options[:exception]
        send_to_action_cable(iteration.story_type, :scheduler, message)
        SlackNotificationJob.perform_now(iteration, "#{type}-scheduling", message)
      end
    end

    private

    def backdate_params(options)
      options.each_with_object([]) { |(_key, schedule), array| array << schedule }
    end

    def auto_params(options)
      options.each_with_object({}) do |(_key, schedule), hash|
        date = schedule[:date]
        time_frame_ids = TimeFrame.where(frame: schedule[:time_frame]).ids
        raise 'Error name in time frame' if time_frame_ids.blank? && !schedule[:time_frame].blank?

        hash[date] = time_frame_ids
      end
    end

    def manual_params(options)
      options.each_with_object([]) { |(_key, schedule), array| array << schedule }
    end
  end
end
