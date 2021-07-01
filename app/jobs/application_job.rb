# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  sidekiq_options retry: false

  private

  def send_to_action_cable(iteration, section, message)
    message_to_send = { iteration_id: iteration.id, message: { key: section, section => message } }

    StoryTypeChannel.broadcast_to(iteration.story_type, message_to_send)
  end

  def generate_story_type_url(story_type)
    host = Rails.env.production? ? 'https://lokic.locallabs.com' : 'http://localhost:3000'
    "#{host}#{Rails.application.routes.url_helpers.story_type_path(story_type)}"
  end

  def channel(step)
    if Rails.env.production?
      step.eql?('REMINDER') ? 'hle_lokic_reminders' : 'hle_lokic_messages'
    else
      'hle_lokic_development_messages'
    end
  end

  def send_to_dev_slack(iteration, step, raw_message)
    story_type = iteration.story_type
    url = generate_story_type_url(story_type)

    iteration_name = step.eql?(:reminder) ? '' : "(#{iteration.name}) "
    developer_name = story_type.developer&.name || '<!@channel> This story type not distributed!'

    message = "*[ LokiC ] <#{url}|STORY TYPE ##{story_type.id}> #{iteration_name}| #{step} "\
              "| #{developer_name}*\n#{raw_message}".gsub("\n", "\n>")

    channel = channel(step)
    SlackNotificationJob.perform_now(channel, message)

    return unless story_type.developer_slack_id

    message = message.gsub(/#{Regexp.escape(" | #{developer_name}")}/, '')
    SlackNotificationJob.perform_now(story_type.developer_slack_id, message)

    record_to_alerts(story_type, step, raw_message)
  end

  def send_report_to_editors_slack(iteration, url)
    story_type = iteration.story_type
    return unless story_type.developer_fc_channel_name

    channel = Rails.env.production? ? story_type.developer_fc_channel_name : 'hle_lokic_development_messages'
    message = "Exported Stories *##{story_type.id} #{story_type.name} (#{iteration.name})*\n#{url}"
    SlackNotificationJob.perform_now(channel, message)
  end

  def record_to_change_history(story_type, event, note)
    note_to_md5 = Digest::MD5.hexdigest(note)
    text = Text.find_or_create_by!(md5hash: note_to_md5) { |t| t.text = note }
    history_event = HistoryEvent.find_or_create_by!(name: event)

    story_type.change_history.create!(history_event: history_event, note: text)
  end

  def record_to_alerts(story_type, subtype, message)
    note_to_md5 = Digest::MD5.hexdigest(message)
    text = Text.find_or_create_by!(md5hash: note_to_md5) { |t| t.text = message }
    subtype = AlertSubtype.find_or_create_by!(name: subtype.downcase)

    story_type.alerts.create!(subtype: subtype, message: text)
  end
end
