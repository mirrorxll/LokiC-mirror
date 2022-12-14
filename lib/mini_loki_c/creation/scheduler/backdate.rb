# frozen_string_literal: true

module MiniLokiC
  module Creation
    module Scheduler
      module Backdate # :nodoc:
        extend self

        def backdate_scheduler(samples, backdated_rules)
          schedule_args = {}
          iteration = samples.first.iteration
          backdated_rules = backdated_rules.sort_by { |rule| rule.values_at(:time_frame, :where) }.reverse

          backdated_rules.each do |rule|
            samples_backdated = samples_backdated(samples, rule)
            next if samples_backdated.empty?

            publications = samples_backdated.group(:publication_id).count
            publication_dates = (Date.parse(rule[:start_date])..Date.parse(rule[:end_date])).to_a

            publications.each do |publication_id, count|
              limit = (count.to_f / publication_dates.length).ceil
              samples_backdated.where(publication: publication_id).find_in_batches(batch_size: limit).with_index do |samples_batch, index|
                samples_batch.each do |sample|
                  return if iteration.story_type.reload.sidekiq_break.cancel

                  sample.update_attributes(published_at: publication_dates[index], backdated: true)
                end
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
          return samples if rule[:time_frame].blank? && rule[:where].blank?

          unless rule[:time_frame].blank?
            rule[:time_frame_ids] = time_frame_ids(rule[:time_frame])
            samples = samples.where(time_frame: rule[:time_frame_ids])
          end

          unless rule[:where].blank?
            stage_ids = ExtraArgs.stage_ids(samples.first.iteration.story_type.staging_table.name, rule[:where])
            samples = samples.where(staging_row_id: stage_ids)
          end
          samples
        end

        def time_frame_ids(time_frame)
          time_frame_ids = TimeFrame.where(frame: time_frame).ids
          raise 'Error name of time frame' if time_frame_ids.blank?
          time_frame_ids
        end
      end
    end
  end
end
