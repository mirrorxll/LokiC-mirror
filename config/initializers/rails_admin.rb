# frozen_string_literal: true

RailsAdmin.config do |config|
  config.asset_source = :webpacker
  config.main_app_name = proc { |c| ['LOKIC', c.params[:action].try(:titleize)] }
  ### Popular gems integration

  config.authorize_with do
    account = Account.find_by(auth_token: cookies.encrypted[:remember_me] || session[:auth_token])
    redirect_to main_app.sign_in_path, flash: { error: { rails_admin: 'please sign in to continue..' } } if account.nil?
  end

  config.current_user_method do
    Account.find_by(auth_token: cookies.encrypted[:remember_me] || session[:auth_token])
  end

  config.included_models =
    %w[
      FactoidType FactoidTypeIteration Assembled
      Client ClientsReport Comment CronTab DataSet DataSetCategory
      Frequency Level PhotoBucket Publication Reminder ScrapeTask SlackAccount StagingTable
      State Status StoryType StoryTypeIteration Tag Task TimeFrame
    ]
end
