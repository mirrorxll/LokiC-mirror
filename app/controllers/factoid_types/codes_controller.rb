# frozen_string_literal: true

module FactoidTypes
  class CodesController < FactoidTypesController # :nodoc:
    before_action :download_code, only: %i[attach reload]

    def show
      @ruby_code =
        CodeRay.scan(@factoid_type.code.download, :ruby).div(line_numbers: :table)
    end

    def attach
      render_403 && return if @factoid_type.code.attached? || @code.nil?

      @factoid_type.code.attach(io: StringIO.new(@code), filename: "f#{@factoid_type.id}.rb")
    end

    def reload
      render_403 && return if @code.nil?

      @factoid_type.code.purge
      @factoid_type.code.attach(io: StringIO.new(@code), filename: "f#{@factoid_type.id}.rb")
    end

    private

    def download_code
      @code = @factoid_type.download_code_from_db
    end
  end
end
