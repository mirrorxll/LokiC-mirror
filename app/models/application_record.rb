# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  attr_accessor :current_account

  self.abstract_class = true

  connects_to database: { writing: :primary, reading: :primary }

  def record_to_change_history(model, event, note, account)
    model.change_history.create!(event: event, note: note, account: account)
  end

  private

  def tracking_changes(model)
    mod = Kernel.const_get("#{model}s")
    model_iteration = Kernel.const_get("#{model}Iteration")
    changes = {}
    changes['renamed'] = "#{name_change.first} -> #{name}" if name_changed?

    if developer_id_changed?
      old_developer = Account.find_by(id: developer_id_change.first)

      old_developer_name = old_developer&.name || 'not distributed'
      new_developer_name = developer&.name || 'not distributed'
      changes['distributed'] = "#{old_developer_name} -> #{new_developer_name}"

      mod::SlackIterationNotificationJob.perform_async(iteration.id, 'developer', 'Unpinned', old_developer.id) if old_developer
      mod::SlackIterationNotificationJob.perform_async(iteration.id, 'developer', 'Distributed to you', developer.id) if developer
    end

    if current_iteration_id_changed? && !current_iteration_id_change.first.nil?
      old_iteration = model_iteration.find_by(id: current_iteration_id_change.first)
      new_iteration = iteration

      old_iteration_id_name = "#{old_iteration.id}|#{old_iteration.name}"
      new_iteration_id_name = "#{new_iteration.id}|#{new_iteration.name}"
      changes['iteration changed'] = "#{old_iteration_id_name} -> #{new_iteration_id_name}"
    end

    if status_id_changed?
      old_status_name = Status.find_by(id: status_id_change.first).name
      new_status_name = status.name
      changes['progress status changed'] = "#{old_status_name} -> #{new_status_name}"

      mod::SlackIterationNotificationJob.perform_async(iteration.id, 'status', changes['progress status changed'], current_account)
    end

    if model.eql?(StoryType)
      if data_set_id_changed?
        old_data_set_name = DataSet.find_by(id: data_set_id_change.first)&.name || 'not selected'
        new_data_set_name = data_set&.name || 'not selected'
        changes['data set changed'] = "#{old_data_set_name} -> #{new_data_set_name}"
      end

      if frequency_id_changed?
        old_frequency_name = Frequency.find_by(id: frequency_id_change.first)&.name || 'not selected'
        new_frequency_name = frequency&.name || 'not selected'
        changes['frequency changed'] = "#{old_frequency_name} -> #{new_frequency_name}"
      end

      if photo_bucket_id_changed?
        old_photo_bucked_name = PhotoBucket.find_by(id: photo_bucket_id_change.first)&.name || 'not selected'
        new_photo_bucked_name = photo_bucket&.name || 'not selected'
        changes['photo bucked changed'] = "#{old_photo_bucked_name} -> #{new_photo_bucked_name}"
      end
    end

    changes.each { |ev, ch| record_to_change_history(self, ev, ch, current_account) }
  end
end
