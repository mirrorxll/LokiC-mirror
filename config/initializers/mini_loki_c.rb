# frozen_string_literal: true

MiniLokiC.configure do |mlc|
  # access to Mysql hosts
  mlc.mysql_regular_user = Rails.application.credentials.mysql[:regular][:user]
  mlc.mysql_regular_password = Rails.application.credentials.mysql[:regular][:password]

  # access to Mysql PL replica host
  mlc.mysql_pl_replica_user = Rails.application.credentials.mysql[:pl_replica][:user]
  mlc.mysql_pl_replica_password = Rails.application.credentials.mysql[:pl_replica][:password]

  # access to postgreSQL hosts
  mlc.postgresql_user = Rails.application.credentials.postgresql[:user]
  mlc.postgresql_password = Rails.application.credentials.postgresql[:password]
end
