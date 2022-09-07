class ExceptionRecord < ApplicationRecord
  serialize :requested_params, Hash

  belongs_to :account
end
