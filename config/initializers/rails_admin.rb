# frozen_string_literal: true

RailsAdmin.config do |config|
  config.main_app_name = proc { |c| ['LokiC', c.params[:action].try(:titleize)] }
  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :account
  end
  config.current_user_method(&:current_account)

  # config.actions do
  #   dashboard { statistics false }
  #
  #   index
  #   new
  #   export
  #   bulk_delete
  #   show
  #   edit
  #   delete
  #   show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  # end
end
