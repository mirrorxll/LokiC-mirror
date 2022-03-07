# frozen_string_literal: true

module MiniLokiC
  module Creation
    module Scheduler
      module PressRelease # :nodoc:
        module_function

        def run(samples)
          return if samples.empty?

          story_type = samples.first.story_type
          time_frames_ids = samples.uniq { |story| story[:time_frame_id] }.map { |story| story[:time_frame_id] }

          time_frames_ids.each do |time_frame_id|
            samples_ttme_frame = samples.where(time_frame: time_frame_id)
            frame = TimeFrame.find(time_frame_id).frame
            date = Date.parse("#{frame.split(':').last}-01-01") + frame.split(':')[1].to_i - 1
            next_published_at = story_type.stories.where('published_at > ?', date.to_s).uniq { |story| story[:published_at] }.map { |story| story[:published_at] }
            count = samples_ttme_frame.length
            if count <= 5
              samples_ttme_frame.each { |sample| sample.update(published_at: date.to_s) }
            else
              samples_ttme_frame.first(5).each { |sample| sample.update(published_at: date.to_s) }
              samples_ttme_frame.where(published_at: nil).each do |sample|
                loop do
                  date = date + 1
                  unless next_published_at.include? date
                    sample.update(published_at: date.to_s)
                    next_published_at << date
                    break
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
