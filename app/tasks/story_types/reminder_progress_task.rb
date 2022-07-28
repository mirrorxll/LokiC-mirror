# frozen_string_literal: true

module StoryTypes
  class ReminderProgressTask < StoryTypesTask
    def perform(*_args)
      account = Account.find_by(email: 'main@lokic.loc')

      StoryType.all.each do |st_type|
        sleep(rand)

        next if st_type.developer.nil? || st_type.status.name.in?(%w[canceled blocked done archived])

        active = true
        old_status = st_type.status.name
        distributed_gap = (Date.today - st_type.distributed_at.to_date).to_i
        last_status_change_gap = (Date.today - st_type.last_status_changed_at.to_date).to_i
        created_at_gap = (Date.today - st_type.created_at.to_date).to_i

        # not migrated story type not started more than seven days
        if st_type.status.name.in?(['created and in queue']) && distributed_gap > 7 && !st_type.migrated
          message(st_type, :story_type_not_started)
          active = false
        end

        # status not changed during two weeks or more
        if st_type.status.name.in?(['in progress']) && last_status_change_gap > 14
          message(st_type, :story_type_not_exported)
          active = false
        end

        # not completed migration
        if created_at_gap > 14 && st_type.migrated && (!st_type.staging_table || !st_type.code.attached?)
          message(st_type, :not_completed_migration)
        end

        next if active || old_status.eql?('inactive')

        st_type.update!(status: Status.find_by(name: 'inactive'), current_account: account)
      end
    end

    private

    def message(story_type, type)
      inactive_sentence = ". Progress Status changed to 'inactive'"
      last_sentence = '. If you have some problems '\
                      'with this Story Type or this alert is false '\
                      "please contact with data's sheriff or manager"

      message =
        case type
        when :story_type_not_started
          "Story Type hasn't started yet#{inactive_sentence}#{last_sentence}"
        when :story_type_not_exported
          "Story Type has status 'in progress' more than two weeks and still "\
          "not exported#{inactive_sentence}#{last_sentence}"
        when :not_completed_migration
          "Story Type hasn't completed migration. please refactor the code "\
          "and attach this to the story type along with the staging table#{last_sentence}"
        end

      SlackReminderNotificationTask.new.perform(story_type.id, message)
    end
  end
end
