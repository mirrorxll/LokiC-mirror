# frozen_string_literal: true

module MiniLokiC
  module Creation
    module Scheduler
      module Auto # :nodoc:
        def self.run_auto(samples, options)
          if options.blank?
            auto_scheduler(samples, options)
          else
            options = options.sort_by { |_start_date, time_frame_ids| time_frame_ids }.reverse
            options.each do |start_date, time_frame_ids|
              if time_frame_ids.blank?
                auto_scheduler(samples.where(published_at: nil), start_date)
              else
                auto_scheduler(samples.where(published_at: nil).where(time_frame: time_frame_ids), start_date)
              end
            end
          end
        end

        def self.auto_scheduler(samples, start_date)
          frequency = samples.first.iteration.story_type.frequency
          frequency = frequency.nil? ? frequency_from_time_frame(samples.first) : frequency.name
          case frequency
          when 'daily'
            schedule_daily(samples)
          when 'weekly'
            schedule_other_frequencies(samples, 75, 7, start_date.blank? ? Date.today : Date.parse(start_date))
          when 'monthly'
            schedule_other_frequencies(samples, 50, 30, start_date.blank? ? Date.today + 3 : Date.parse(start_date))
          when 'quarterly'
            schedule_other_frequencies(samples, 70, 90, start_date.blank? ? Date.today + 3 : Date.parse(start_date))
          when 'biannually'
            schedule_other_frequencies(samples, 50, 150, start_date.blank? ? Date.today + 2 : Date.parse(start_date))
          when 'annually'
            schedule_annually(samples, start_date)
          else
            raise ArgumentError, 'Error in frequency'
          end
        end

        def self.frequency_from_time_frame(sample)
          case sample.first.time_frame.frame[0]
          when 'd'
            'daily'
          when 'w'
            'weekly'
          when 'm'
            'monthly'
          when 'q'
            'quarterly'
          when 'b'
            'biannually'
          when '2'
            'annually'
          else
            raise ArgumentError, 'Error in time frame'
          end
        end

        def self.get_time_frame_ids(samples)
          samples.select(:time_frame_id).group(:time_frame_id)
        end

        def self.schedule_other_frequencies(samples, limit, total_days_till_end, start_publish_date)
          time_frame_ids = get_time_frame_ids(samples)
          time_frame_ids.each_with_index do |frame, index|
            backdated_date =
              if index.zero?
                Date.today - 1
              else
                smpls = samples.where(time_frame: time_frame_ids[index - 1][:time_frame_id])
                smpls.sort_by { |sample| sample[:published_at] }.reverse.first[:published_at]
              end

            samples_time_frame = samples.where(time_frame: frame[:time_frame_id])
            start_publish_date = index.zero? ? start_publish_date.strftime('%Y-%m-%d') : (backdated_date + 1).strftime('%Y-%m-%d')
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
                total_days_till_end: total_days_till_end.to_s,
                previous_date: 1
              }
              Base.old_scheduler(samples_time_frame, params)
            else
              frame = TimeFrame.find_by(id: frame[:time_frame_id]).frame
              day_from_frame = frame.split(':')[1].to_i
              year_from_frame = frame.split(':').last.to_i

              date_story_is_about = Date.ordinal(year_from_frame, day_from_frame)

              backdated_date = (date_story_is_about + 2).strftime('%Y-%m-%d')

              Backdate.backdate_scheduler(samples_time_frame, { backdated_date => '' })
            end
          end
        end

        def self.schedule_annually(samples, start_date)
          time_frame_ids = get_time_frame_ids(samples)
          previous_year = Time.now.year - 1
          time_frame_ids.each do |frame|
            year_from_frame = TimeFrame.find_by(id: frame[:time_frame_id]).frame.to_i
            start_publish_date = start_date.blank? ? (Date.today + 3).strftime('%Y-%m-%d') : start_date
            limit = 50
            samples_time_frame = samples.where(time_frame: frame[:time_frame_id])
            total_days_till_end = (Date.parse(start_publish_date)..Date.parse("#{Time.now.year}-12-31")).count
            total_days_till_end = 120 if total_days_till_end < 60 # if start date > November 1
            backdated_date = (Date.parse("#{Time.now.year}-01-01")..(Date.today - 1)).to_a.sample.strftime('%Y-%m-%d')
            unless year_from_frame == previous_year
              total_days_till_end = total_days_till_end >= 200 ? 200 : total_days_till_end
            end
            run(start_publish_date, limit, total_days_till_end, backdated_date, samples_time_frame)
          end
        end

        def self.run(start_publish_date, limit, total_days_till_end, backdated_date, samples_time_frame)
          params = {
            start_date: start_publish_date,
            limit: limit,
            total_days_till_end: total_days_till_end.to_s,
            previous_date: 1
          }
          Base.old_scheduler(samples_time_frame, params)
          return if samples_time_frame.where(published_at: nil).empty?

          Backdate.backdate_scheduler(
            samples_time_frame, { backdated_date => '' }
          )
        end
      end
    end
  end
end
