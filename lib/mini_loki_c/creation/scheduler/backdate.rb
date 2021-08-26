# frozen_string_literal: true

module MiniLokiC
  module Creation
    module Scheduler
      module Backdate # :nodoc:
        def self.backdate_scheduler(samples, backdated_rules)
          schedule_args = {}
          backdated_rules = backdated_rules.sort_by { |rule| [rule[:time_frame_ids], rule[:where]] }.reverse

          backdated_rules.each do |rule|
            samples_backdated = samples_backdated(samples, rule)

            next if samples_backdated.empty?

            publications = samples_backdated.group(:publication_id).count
            publication_dates = (rule[:begin_date]..rule[:end_date]).to_a

            publications.each do |publication_id, count|
              limit = (count.to_f / publication_dates.length).ceil

              samples_backdated.where(publication: publication_id).find_in_batches(batch_size: limit).with_index do |samples_batch, index|
                samples_batch.each { |sample| sample.update_attributes(published_at: publication_dates[index], backdated: true) }
              end
            end
          end

          iteration = samples.first.iteration
          iteration.update_attribute(:schedule, true) if samples.where(published_at: nil).empty?
          schedule_args = schedule_args.to_json
          iteration.update_attribute(:schedule_args, iteration.schedule_args.nil? ? schedule_args : iteration.schedule_args += schedule_args)
        end

        private

        def samples_backdated(samples, rule)
          samples = samples.where(published_at: nil)
          return samples if rule[:time_frame_ids].blank? && rule[:where].blank?

          samples = samples.where(time_frame: rule[:time_frame_ids]) unless rule[:time_frame_ids].blank?

          unless rule[:where].blank?
            stage_ids = ExtraArgs.stage_ids(samples.first.iteration.story_type.staging_table.name, rule[:where])
            samples = samples.where(staging_row_id: stage_ids)
          end
          samples
        end
      end
    end
  end
end
