class LimparRecord < ActiveRecord::Base
  self.abstract_class = true

  establish_connection LIMPAR_DB
end
