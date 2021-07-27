# frozen_string_literal: true

module MiniLokiC
  module Creation
    module Scheduler
      module Backdate # :nodoc:
        def self.backdate_scheduler(samples, backdated_data)
          schedule_args = {}
          backdated_data = backdated_data.sort_by { |time_frame, _dates| time_frame }.reverse

          backdated_data.each do |time_frame, dates|
            samples_backdated = if time_frame.blank?
                                  samples.where(published_at: nil)
                                else
                                  time_frame_ids = TimeFrame.where(frame: time_frame).ids
                                  raise 'Error name of time frame' if time_frame_ids.blank?
                                  samples.where(published_at: nil).where(time_frame: time_frame_ids)
                                end

            next if samples_backdated.empty?

            publications = samples_backdated.group(:publication_id).count
            publication_dates = (dates[0]..dates[1]).to_a

            publications.each do |publication_id, count|
              limit = (count.to_f / publication_dates.length).ceil

              puts 'LIMIttttt'
              puts limit
              samples_backdated.where(publication: publication_id).find_in_batches(batch_size: limit).with_index do |samples_batch, index|
                puts 'loop'
                puts samples_batch.length
                puts index
                puts publication_dates[index]
                samples_batch.each { |sample| sample.update_attributes(published_at: publication_dates[index], backdated: true) }
              end
            end
          end

          iteration = samples.first.iteration
          iteration.update_attribute(:schedule, true) if samples.where(published_at: nil).empty?
          schedule_args = schedule_args.to_json
          iteration.update_attribute(:schedule_args, iteration.schedule_args.nil? ? schedule_args : iteration.schedule_args += schedule_args)
        end
      end
    end
  end
end
