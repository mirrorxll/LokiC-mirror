# frozen_string_literal: true

require_relative '../mini_loki_c/connect/mysql'

module Schedule
  module BackdateScheduler # :nodoc:
    def self.backdate_scheduler(samples, dates, args = nil)
      backdated_data = {}
      dates.each_with_index { |date, index| backdated_data[date] = args[index] }
      backdated_data = backdated_data.sort_by { |_date, arg| arg }.reverse
      schedule_args = 'backdated: '
      backdated_data.each_with_index do |(date, arg), index|
        samples = samples.where(published_at: nil)
        break if samples.empty?

        if arg.nil? || arg == ''
          samples.each { |sample| sample.update_attributes(published_at: date, backdated: true)}
          schedule_args += "#{date}"
        else
          stage_ids = ExtraArgs.get_stage_ids(samples.first.iteration.story_type.staging_table.name, arg)
          samples.where(id: stage_ids).each { |sample| sample.update_attributes(published_at: date, backdated: true) }
          schedule_args += "#{date}:#{arg}"
        end
        schedule_args += backdated_data.length == index + 1 ? ';' : ', '
      end

      iteration = Iteration.find_by(id: samples.first.iteration_id)
      iteration.update_attribute(:schedule, true) if samples.where(published_at: nil).empty?
      iteration.update_attribute(:schedule_args, iteration.schedule_args += schedule_args)
    end
  end
end