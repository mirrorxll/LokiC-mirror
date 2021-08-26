# frozen_string_literal: true

module StoryTypes
  class SchedulerJob < StoryTypeJob
    def perform(iteration, type, options = {}, account = nil)
      status = nil
      message = 'Success'
      story_type = iteration.story_type
      account ||= story_type.developer

      rd, wr = IO.pipe

      Process.wait(
        fork do
          rd.close
          samples = iteration.stories

          case type
          when :manual
            MiniLokiC::Creation::Scheduler::Base.run_schedule(samples, manual_params(options))
          when :backdate
            MiniLokiC::Creation::Scheduler::Backdate.backdate_scheduler(samples, backdate_params(options))
          when :auto
            MiniLokiC::Creation::Scheduler::Auto.run_auto(samples, auto_params(options))
          when :run_from_code
            MiniLokiC::Creation::Scheduler::FromCode.run_from_code(samples, options)
          end

          record_to_change_history(story_type, 'scheduled', type, account)
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

      status = true if iteration.reload.stories.where(published_at: nil).none?

      true
    rescue StandardError => e
      status = nil
      message = e.message
    ensure
      iteration.update!(schedule: status)
      send_to_action_cable(iteration.story_type, :scheduler, message)
      SlackNotificationJob.perform_now(iteration, "#{type}-scheduling", message)
    end

    private

    def backdate_params(options)
      options.each_with_object([]) do |(_key, schedule), array|
        schedule[:time_frame_ids] = time_frame_ids(schedule[:time_frame])
        array << schedule
      end
    end

    def auto_params(options)
      options.each_with_object({}) do |(_key, schedule), hash|
        date = schedule[:date]
        time_frame_ids = TimeFrame.where(frame: schedule[:time_frame]).ids
        raise 'Error name of time frame' if time_frame_ids.blank? && !schedule[:time_frame].blank?

        hash[date] = time_frame_ids
      end
    end

    def manual_params(options)
      options.each_with_object([]) do |(_key, schedule), array|
        schedule[:time_frame] = time_frame_ids(schedule[:time_frame])
        array << schedule
      end
    end

    def time_frame_ids(time_frame)
      return [] if time_frame.blank?

      time_frame_ids = TimeFrame.where(frame: time_frame).ids
      raise 'Error name of time frame' if time_frame_ids.blank?
      time_frame_ids
    end

  end
end
