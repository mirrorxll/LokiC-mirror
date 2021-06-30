# frozen_string_literal: true

class ClientTag < ApplicationRecord # :nodoc:
  self.table_name = 'clients_tags'

  belongs_to :client
  belongs_to :tag
end
