# frozen_string_literal: true

MiniLokiC.configure do |mlc|
  # access to DB* hosts
  mlc.mysql_regular_user = Rails.application.credentials.mysql[:regular][:user]
  mlc.mysql_regular_password = Rails.application.credentials.mysql[:regular][:password]

  # access to pl replica host
  mlc.mysql_pl_replica_user = Rails.application.credentials.mysql[:pl_replica][:user]
  mlc.mysql_pl_replica_password = Rails.application.credentials.mysql[:pl_replica][:password]
end
