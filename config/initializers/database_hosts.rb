# frozen_string_literal: true

# Host of PL production DB replica (readonly!)
# +--------------------------------------------------------+
# | For common stories code usage:                         |
# |   pl_replica = PipelineReplica[:production].pl_replica |
# |   pl_replica.query('something;')                       |
# |   pl_replica.close                                     |
# +--------------------------------------------------------+
PL_PROD_DB_HOST = 'pipeline-core-replica4.rds.locallabs.com'
# pipeline-core-replica.rds.locallabs.com == jnswire2-readonly.rds.locallabs.com

# Host of PL staging DB replica (readonly!)
PL_STAGE_DB_HOST = 'pl-staging.rds.locallabs.com'
# pl-staging.rds.locallabs.com == pl-staging.c2ygbkoa3qma.us-east-1.rds.amazonaws.com

# PL GIS host (readonly!)
PL_GIS_HOST = 'pl-shapes-staging.rds.locallabs.com'

# PL GIS STAGING host (readonly!)
PL_GIS_STAGING_HOST = 'pl-shapes-staging.rds.locallabs.com'

# PL GIS PROD host (readonly!)
PL_GIS_PROD_HOST = 'pl-shapes.rds.locallabs.com'

# db hosts
DB01 = 'db01.blockshopper.com'
DB02 = 'db02.blockshopper.com'
DB04 = 'db04.blockshopper.com'
# DB05 = 'db05.blockshopper.com'
DB05 = '10.0.1.101'
DB06 = 'db06.blockshopper.com'
DB07 = 'db07.blockshopper.com'
DB08 = 'db08.rds.blockshopper.com'
# DB09 = 'db09.blockshopper.com'.freeze
DB10 = 'db10.blockshopper.com'
# db12 was migrated to db01 2020-02-21
# DB12 = 'db12.blockshopper.com'.freeze
DB13 = 'db13.blockshopper.com'
DB14 = 'db14.blockshopper.com'
DB15 = 'db15.blockshopper.com'

UPDATED_MB4_BASES = [{ host: DB02, database: 'twitter' }, { host: DB02, database: 'loki_storycreator' }]

# PostgreSQL DB of locallabs
DB_LIMPAR_LL = 'limpar.rds.locallabs.com'

# to convert short names like 'db05' to corresponding constant value
def full_db_name(name)
  name.include?('blockshopper.com') ? name : Object.const_get(name.to_s.upcase)
end
