# frozen_string_literal: true

module Scheduler
  module Backdate # :nodoc:
    def self.backdate_scheduler(samples, backdated_data)
      schedule_args = {}
      backdated_data = backdated_data.sort_by { |_date, arg| arg }.reverse

      backdated_data.each do |date, arg|
        samples_backdated = samples.where(published_at: nil)
        next if samples.empty?

        if arg.empty?
          samples_backdated.each { |smpl| smpl.update_attributes(published_at: date, backdated: true) }
          schedule_args[date.to_s] = ''
        else
          staging_table_name = samples_backdated.first.iteration.story_type.staging_table.name
          stage_ids = ExtraArgs.stage_ids(staging_table_name, arg)

          samples_backdated.where(staging_row_id: stage_ids).each do |smpl|
            smpl.update_attributes(published_at: date, backdated: true)
          end
          schedule_args[date.to_s] = arg
        end
      end

      iteration = samples.first.iteration
      iteration.update_attribute(:schedule, true) if samples.where(published_at: nil).empty?
      schedule_args = schedule_args.to_json
      iteration.update_attribute(:schedule_args, iteration.schedule_args.nil? ? schedule_args : iteration.schedule_args += schedule_args)
    end
  end
end
