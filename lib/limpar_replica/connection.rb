# frozen_string_literal: true

module LimparReplica
  class Connection
    attr_reader :lp_replica

    def initialize(environment)
      #TODO: if we have staging, or only  production?
      host, database = DB_LIMPAR_LL, 'limpar' if environment.eql?(:production)

      user        = MiniLokiC.postgresql_user
      password    = MiniLokiC.postgresql_password

      @lp_replica = LimparReplica::Pgsql.on(host, database, user, password)
    end

    def close
      @lp_replica.close
    end
  end
end
