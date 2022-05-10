# frozen_string_literal: true

require_relative 'route/parcel.rb'
require_relative 'route/editorials.rb'

module Limpar
  module Route
    include Parcel
    include Editorials
  end
end
