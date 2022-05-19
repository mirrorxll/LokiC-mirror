# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'LokiC <lokic@locallabs.com>'
  layout 'mailer'
end
