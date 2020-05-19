# frozen_string_literal: true

module PipelineReplica
  class Connection
    def initialize(environment)
      host, database =
        if environment.eql?(:production)
          [PL_PROD_DB_HOST, 'jnswire_prod']
        else
          [PL_STAGE_DB_HOST, 'jnswire_staging']
        end

      user = MiniLokiC.mysql_pl_replica_user
      password = MiniLokiC.mysql_pl_replica_password

      @replica = PipelineReplica::Mysql.on(host, database, user, password)
    end

    def close
      @replica.close
    end
  end
end
