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

  def send_to_dev_slack(iteration, step, raw_message)
    story_type = iteration.story_type
    url = generate_story_type_url(story_type)

    iteration_name = step.eql?(:reminder) ? '' : "(#{iteration.name}) "
    developer_name = story_type.developer&.name || '<!@channel> This story type not distributed!'

    message = "*[ LokiC ] <#{url}|STORY TYPE ##{story_type.id}> #{iteration_name}| #{step} "\
              "| #{developer_name}*\n#{raw_message}".gsub("\n", "\n>")

    channel = Rails.env.production? ? 'hle_lokic_messages' : 'lokic_development_messages'
    SlackNotificationJob.perform_now(channel, message)

    return unless story_type.developer_slack_id

    message = message.gsub(/#{Regexp.escape(" | #{developer_name}")}/, '')
    SlackNotificationJob.perform_now(story_type.developer.slack.identifier, message)

    subtype = AlertSubtype.find_or_create_by!(name: step.downcase)
    text = Text.find_or_create_by!(text: raw_message)
    story_type.alerts.create(subtype: subtype, message: text)
  end

  def send_report_to_editors_slack(iteration, url)
    story_type = iteration.story_type
    return unless story_type.developer_fc_channel_name

    channel = Rails.env.production? ? story_type.developer_fc_channel_name : 'lokic_development_messages'
    message = "Exported Stories *##{story_type.id} #{story_type.name} (#{iteration.name})*\n#{url}"
    SlackNotificationJob.perform_now(channel, message)
  end

  def record_to_change_history(story_type, event_name, notes)
    event = HistoryEvent.find_or_create_by!(name: event_name)
    note = Text.find_or_create_by!(text: notes)
    story_type.change_history.create(history_event: event, note: note)
  end
end
