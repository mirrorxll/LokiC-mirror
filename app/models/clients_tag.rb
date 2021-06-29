# frozen_string_literal: true

class ClientsTag < ApplicationRecord # :nodoc:
  belongs_to :client
  belongs_to :tag
end
