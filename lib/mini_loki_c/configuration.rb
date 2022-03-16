# frozen_string_literal: true

module MiniLokiC
  # Set configurations for
  # data base connections
  module Configuration
    CONFIG_KEYS = %i[
      mysql_regular_user
      mysql_regular_password
      mysql_pl_replica_user
      mysql_pl_replica_password
      postgresql_user
      postgresql_password
    ].freeze

    attr_accessor(*CONFIG_KEYS)

    def configure
      yield self
    end
  end
end
