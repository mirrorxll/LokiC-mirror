# frozen_string_literal: true

module MiniLokiC
  module Creation
    module Scheduler
      module Base # :nodoc:
        extend self

        FOUR_WEEKS_IN_DAYS = 4 * 7
        POSSIBLE_FREQUENCY = %w[weekly monthly quarterly].freeze

        ALL_WEEKDAYS = %w[m tu w th f sa su].freeze
        ALL_WEEKDAYS_TEXT = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].freeze

        # day of the week in 0-6. Sunday is day-of-week 0; Saturday is day-of-week 6.
        HASH_WEEKDAYS = {
          'm' => 1,
          'tu' => 2,
          'w' => 3,
          'th' => 4,
          'f' => 5,
          'sa' => 6,
          'su' => 0
        }.freeze

        HASH_WEEKDAYS_TEXT = {
          'm' => 'Monday',
          'tu' => 'Tuesday',
          'w' => 'Wednesday',
          'th' => 'Thursday',
          'f' => 'Friday',
          'sa' => 'Saturday',
          'su' => 'Sunday'
        }.freeze

        def run_schedule(samples, array_options)
          array_options.each { |options| old_scheduler(samples, options) }
        end

        def get_samples(samples, extra_args, time_frame)
          samples = samples.where(time_frame: time_frame) unless time_frame.blank?
          if extra_args.blank?
            samples = samples.where(published_at: nil)
          else
            stage_ids = ExtraArgs.stage_ids(samples.first.iteration.story_type.staging_table.name, extra_args)
            samples = samples.where(published_at: nil).where(staging_row_id: stage_ids)
          end
          samples
        end

        def old_scheduler(samples, options)
          options = check_and_define_args(options)
          iteration = samples.first.iteration

          time_frame_ids = time_frame_ids(options[:time_frame])
          samples = get_samples(samples, options[:extra_args], time_frame_ids)

          publications = samples.group(:publication_id).count

          publications.each do |publication_id, count|

            if options[:limit] && options[:end_date] === false
              tmp_end_date = calculate_end_date(options[:weekdays], options[:frequency], options[:limit], options[:start_date], count)
            end

            publication_dates = all_publication_dates(options[:weekdays], options[:frequency], options[:start_date], tmp_end_date || options[:end_date])

            number_of_stories_per_date = (count.to_f / publication_dates.length).ceil

            if options[:limit] && (options[:limit] < number_of_stories_per_date || options[:end_date] === false)
              number_of_stories_per_date = options[:limit]
              limit_repeats_counter = (count.to_f / options[:limit]).ceil
            end

            max_repeats = limit_repeats_counter && (publication_dates.length > limit_repeats_counter || options[:end_date] === false) ? limit_repeats_counter : publication_dates.length

            stories = samples.select(:id).where(publication_id: publication_id)
            if (stories.count.to_f / max_repeats).ceil >= 1 && (stories.count.to_f / max_repeats).ceil <= number_of_stories_per_date
              number_of_days_with_more_stories = stories.count % max_repeats
            end

            story_ids = {}

            i = 0
            count_stories_per_date = 0
            not_adjusted = true
            stories.each do |story|
              break if iteration.story_type.reload.sidekiq_break.cancel

              count_stories_per_date += 1
              story_ids[i] = [] unless story_ids[i]
              story_ids[i] << story[:id]

              if count_stories_per_date == number_of_stories_per_date
                i += 1
                count_stories_per_date = 0
              end
              if not_adjusted && number_of_days_with_more_stories && number_of_days_with_more_stories > 0 && number_of_days_with_more_stories == i
                number_of_stories_per_date -= 1
                not_adjusted = false
              end
            end

            i = 0
            publication_dates.each do |each_date|
              samples.find(story_ids[i]).each { |sample| sample.update_attribute(:published_at, each_date.strftime('%Y-%m-%d')) }
              i += 1
              break if limit_repeats_counter && i == limit_repeats_counter
              break if i == story_ids.count
            end
          end

          samples_for_iteration = Story.where(iteration: iteration).where(published_at: nil)
          iteration.update_attribute(:schedule, true) if samples_for_iteration.where(published_at: nil).empty?
          schedule_args = schedule_args_to_hash(options)
          iteration.update_attribute(:schedule_args, iteration.schedule_args.nil? ? schedule_args : iteration.schedule_args += schedule_args)
        end

        def time_frame_ids(time_frame)
          return [] if time_frame.blank?

          time_frame_ids = TimeFrame.where(frame: time_frame).ids
          raise 'Error name of time frame' if time_frame_ids.blank?
          time_frame_ids
        end

        def schedule_args_to_hash(options)
          hash = {}
          hash[:st] = options[:start_date]
          hash[:lm] = options[:limit]
          hash[:td] = options[:total_days_till_end]
          hash[:wh] = options[:extra_args].nil? ? '' : options[:extra_args]
          hash.to_json
        end

        # Set default values if args have not been passed
        def check_and_define_args(args)
          unless args[:limit] || args[:end_date] || args[:total_days_till_end]
            raise ArgumentError, 'you need to provide limit and/or end_date/total days till end date args!'
          end

          args[:start_date] = Date.parse(args[:start_date]) if args[:start_date]
          args[:end_date] = Date.parse(args[:end_date]) if args[:end_date]
          args[:start_date] = Date.today unless args[:start_date]

          if args[:start_date] < Date.today && args[:previous_date].to_i.zero?
            raise ArgumentError, 'invalid start_date - should be >= today! (correct format: yyyy-mm-dd)'
          end

          if args[:limit]&.to_i && args[:limit].to_i > 0
            args[:limit] = args[:limit].to_i
          elsif args[:limit]
            raise ArgumentError, 'invalid limit (needs to be an int value, > 0)'
          end

          unless args[:total_days_till_end].to_s.empty?
            if args[:end_date]
              raise ArgumentError, "invalid options - total_days_till_end_date can't be used with end_date - choose one"
            elsif args[:total_days_till_end].to_i < 1
              raise ArgumentError, 'invalid total_days_till_end_date - should be integer > 0'
            end
          end

          if args[:total_days_till_end].to_i > 0
            args[:end_date] = args[:start_date] + args[:total_days_till_end].to_i - 1
          end
          if args[:weekdays]
            weekdays = args[:weekdays].split(/[ ,]+/) if /[ ,]+/.match(args[:weekdays])
            if weekdays&.is_a?(Array) && !(weekdays & ALL_WEEKDAYS).empty?
              args[:weekdays] = weekdays
            else
              raise ArgumentError, 'invalid weekdays (needs to be comma and/or space separated; possible values are: m tu w th f sa su)'
            end
          end

          if args[:frequency]
            unless POSSIBLE_FREQUENCY.include? args[:frequency]
              raise ArgumentError, 'invalid frequency (only accepts: weekly, monthly or quarterly)'
            end
          end

          args[:weekdays] = ALL_WEEKDAYS unless args[:weekdays]
          args[:frequency] = 'weekly' unless args[:frequency]

          args[:end_date] = false unless args[:end_date]

          if args[:overwrite] && (args[:overwrite] != 'true' && args[:overwrite] != 'force' && args[:overwrite] != 'false' && args[:overwrite] != 0.to_s && args[:overwrite] != 1.to_s)
            raise ArgumentError, 'invalid overwrite arg (needs to be force, true, false, 0 or 1)'
          end

          if args[:overwrite] && (args[:overwrite] == 'true' || args[:overwrite] == 1.to_s)
            args[:overwrite] = true
          elsif args[:overwrite] != 'force'
            args[:overwrite] = false
          end

          if args[:end_date] && args[:end_date] < args[:start_date]
            raise ArgumentError, 'invalid end_date - should be >= start_date! (correct format: yyyy-mm-dd)'
          end

          args
        end

        # Returns array with all days that match args [Dates]
        def all_publication_dates(weekdays, frequency, start_date, end_date)
          if frequency == 'weekly'
            all_days_weekly_till_end_date(weekdays, start_date, end_date)
          else
            all_days_monthly_or_quarterly_till_end_date(weekdays, frequency, start_date, end_date)
          end
        end

        # Returns approximate end_date considering args
        def calculate_end_date(weekdays, frequency, limit, start_date, count)
          export_days = (count.to_f / limit).ceil
          weeks = (export_days.to_f / weekdays.length).ceil
          days_till_end_of_week = 6 - start_date.wday
          start_date += days_till_end_of_week
          case frequency
          when 'weekly'
            start_date + (weeks * 7)
          when 'monthly'
            (start_date >> weeks)
          when 'quarterly'
            (start_date >> (weeks * 3))
          end
        end

        # Returns date of next weekday in param
        # param day accepts:  m tu w th f sa su
        #                     Monday Tuesday Wednesday Thursday Friday Saturday Sunday
        #                     0-6
        def date_of_next(weekday)
          if ALL_WEEKDAYS_TEXT.include?(weekday) || HASH_WEEKDAYS_TEXT[weekday] || (0..6).to_a.include?(weekday)
            date_to_parse = if (0..6).to_a.include? weekday
                              ALL_WEEKDAYS_TEXT[weekday]
                            else
                              ((ALL_WEEKDAYS_TEXT.include? weekday) ? weekday : HASH_WEEKDAYS_TEXT[weekday])
                            end
            date = Date.parse(date_to_parse)
            delta = date > Date.today ? 0 : 7
            date + delta
            return date
          end
          false
        end

        # Returns next day in a period of months with same weekday of date in param
        def future_month_same_weekday(date, period_in_months = 1)
          date_next_month = date + period_in_months * FOUR_WEEKS_IN_DAYS

          if date_next_month.mon == (date >> period_in_months).mon
            date_next_month
          else
            date_next_month + 7
          end
        end

        # Returns next day in a quarter with same weekday of date in param
        def future_quarter_same_weekday(date)
          future_month_same_weekday(date, 3)
        end

        # Returns all days of weekdays in param from start_date till end_date
        # param day: accepts: m tu w th f sa su
        def all_days_weekly_till_end_date(weekdays, start_date = Date.today, end_date)
          wk_days = []
          weekdays.each { |k| wk_days << HASH_WEEKDAYS[k] }
          (start_date..end_date).to_a.select { |k| wk_days.include?(k.wday) }
        end

        # Returns days of weekdays in param from start_date till end_date by each month or quarter
        # param day: accepts: m tu w th f sa su
        def all_days_monthly_or_quarterly_till_end_date(weekdays, frequency = 'monthly', start_date = Date.today, end_date)
          method_to_call = frequency == 'quarterly' ? 'future_quarter_same_weekday' : 'future_month_same_weekday'
          wk_days = []
          weekdays.each { |k| wk_days << HASH_WEEKDAYS[k] }

          verified_days = (start_date..start_date + 6).to_a.select { |k| wk_days.include?(k.wday) }

          days = verified_days

          while verified_days != [] && verified_days.last <= end_date
            tmp_days = []
            verified_days.each do |k|
              tmp_days << method(:"#{method_to_call}").call(k) if method(:"#{method_to_call}").call(k) <= end_date
            end
            verified_days = tmp_days
            days += verified_days
          end

          days.sort
        end
      end
    end
  end
end
