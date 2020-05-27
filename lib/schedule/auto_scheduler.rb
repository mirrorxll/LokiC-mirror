# frozen_string_literal: true

require_relative '../mini_loki_c/connect/mysql'
require_relative 'old_scheduler'
require_relative 'backdate_scheduler'

module Schedule
  module AutoScheduler # :nodoc:
    def self.auto_scheduler(samples)
      frequency = samples.first.iteration.story_type.frequency.name
      case frequency
      when 'daily'
        schedule_daily(samples)
      when 'weekly'
        schedule_other_frequencies(samples, 5, 2, Date.today)
      when 'monthly'
        schedule_other_frequencies(samples, 2, 2, Date.today + 3)
      when 'quarterly'
        schedule_other_frequencies(samples, 70, 90, Date.today + 3)
      when 'biannually'
        schedule_other_frequencies(samples, 50, 150, Date.today + 2)
      when 'annually'
        schedule_annually(samples)
      else
        raise ArgumentError, 'Error in frequency'
      end
    end

    def self.get_time_frame_ids(samples)
      samples.select(:time_frame_id).group(:time_frame_id)
    end

    def self.schedule_other_frequencies(samples, limit, total_days_till_end, start_publish_date)
      time_frame_ids = get_time_frame_ids(samples)
      time_frame_ids.each_with_index do |frame, index|
        if index == 0
          backdated_date = Date.today
        else
          backdated_date = samples.where(time_frame: time_frame_ids[index - 1][:time_frame_id]).sort_by { |sample| sample[:published_at] }.reverse.first[:published_at]
        end

        samples_time_frame = samples.where(time_frame: frame[:time_frame_id])

        start_publish_date = index == 0 ? start_publish_date.strftime('%Y-%m-%d') : (backdated_date + 1).strftime('%Y-%m-%d')

        run(start_publish_date, limit, total_days_till_end, backdated_date, samples_time_frame)
      end
    end

    def self.schedule_daily(samples)
      time_frame_ids = get_time_frame_ids(samples)
      time_frame_ids.each_with_index do |frame, index|
        samples_time_frame = samples.where(time_frame: frame[:time_frame_id])
        if index == time_frame_ids.length - 1
          limit = samples_time_frame.length
          total_days_till_end = 1
          start_publish_date = Date.today.strftime('%Y-%m-%d')
          params = {
            start_date: start_publish_date,
            limit: limit,
            total_days_till_end_date: total_days_till_end
          }
          OldScheduler.old_scheduler(samples_time_frame, params)
        else
          frame = TimeFrame.find_by(id: frame[:time_frame_id]).frame
          day_from_frame = frame.split(',').first.to_i
          year_from_frame = frame.split(',').last.to_i

          date_story_is_about = Date.ordinal(year_from_frame, day_from_frame)

          backdated_date = (date_story_is_about - 2).strftime('%Y-%m-%d')

          BackdateScheduler.backdate_scheduler(samples_time_frame, [backdated_date])
        end
      end
    end

    def self.schedule_annually(samples)
      time_frame_ids = get_time_frame_ids(samples)
      previous_year = Time.now.year - 1
      time_frame_ids.each do |frame|
        year_from_frame = TimeFrame.find_by(id: frame[:time_frame_id]).frame.to_i
        start_publish_date = (Date.today + 3).strftime('%Y-%m-%d')
        limit = 2
        samples_time_frame = samples.where(time_frame: frame[:time_frame_id])
        total_days_till_end = (Date.parse(start_publish_date)..Date.parse("#{Time.now.year}-12-31")).count
        backdated_date = (Date.parse("#{Time.now.year}-01-01")..(Date.today - 1)).to_a.sample.strftime('%Y-%m-%d')
        total_days_till_end = total_days_till_end >= 200 ? 200 : total_days_till_end unless year_from_frame == previous_year
        run(start_publish_date, limit, total_days_till_end, backdated_date, samples_time_frame)
      end
    end

    def self.run(start_publish_date, limit, total_days_till_end, backdated_date, samples_time_frame)
      params = {
        start_date: start_publish_date,
        limit: limit,
        total_days_till_end_date: total_days_till_end
      }
      OldScheduler.old_scheduler(samples_time_frame, params)
      return unless samples_time_frame.where(published_at: nil).empty?

      BackdateScheduler.backdate_scheduler(
        samples_time_frame, [backdated_date]
      )
    end
  end
end