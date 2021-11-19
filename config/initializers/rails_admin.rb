# frozen_string_literal: true

RailsAdmin.config do |config|
  config.main_app_name = proc { |c| ['LokiC', c.params[:action].try(:titleize)] }
  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :account
  end
  config.current_user_method(&:current_account)

  # this is the way to whitelist the models
  config.included_models =
    %w[
      Account AccountType Article ArticleType ArticleTypeIteration Assembled
      Client ClientsReport Comment CronTab DataSet DataSetCategory
      Frequency Level PhotoBucket Publication Reminder ScrapeTask SlackAccount StagingTable
      State Status StoryType StoryTypeIteration Tag Task TimeFrame
    ]
end

