# frozen_string_literal: true

module StoryTypes
  class CreationsController < StoryTypesController # :nodoc:
    def execute
      @iteration.update!(creation: false, current_account: current_account)
      send_to_action_cable(@story_type, 'samples', 'creation in the process2222222222222222')

      Process.spawn(
        "cd #{Rails.root} && RAILS_ENV=#{Rails.env} "\
        'rake story_type:iteration:creation '\
        "iteration_id=#{@iteration.id} account_id=#{current_account.id} &"
      )
    end

    def purge
      if @iteration.stories.where.not("pl_#{PL_TARGET}_story_id" => nil).present?
        flash.now[:error] = 'At least one story from this iteration has already exported to PL'
      else
        @iteration.update!(purge_creation: true, current_account: current_account)
        send_to_action_cable(@story_type, 'samples', 'purging in progress')

        Process.spawn(
          "cd #{Rails.root} && RAILS_ENV=#{Rails.env} "\
          'rake story_type:iteration:purge_creation '\
          "iteration_id=#{@iteration.id} account_id=#{current_account.id} &"
        )
      end
    end
  end
end
