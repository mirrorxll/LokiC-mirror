# frozen_string_literal: true

class ClientOpportunity < ApplicationRecord # :nodoc:
  self.table_name = 'clients_opportunities'

  belongs_to :client
  belongs_to :opportunity
end
