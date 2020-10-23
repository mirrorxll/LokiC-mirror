# frozen_string_literal: true

module MiniLokiC
  module Formatize
    module The

      EXPRESSIONS = []

      module_function

      # Gets rule regular expressions from DB
      def define
        query = 'select expression, type from definite_article;'
        EXPRESSIONS.replace(MiniLokiC::Connect::Mysql.exec_query(DB02, 'lokic_tools', query, true).to_a)
      end

      # Adds definite article before a string if it is satisfy the conditions
      def self.[](text, prefix = false)
        expressions = {}
        EXPRESSIONS.map { |el| (expressions[el[:type]] ||= []) << el[:expression] }

        starts     = Regexp.new("^(#{expressions['starts'].join('|')})\\b", Regexp::IGNORECASE)
        ends       = Regexp.new("\\b(#{expressions['ends'].join('|')})$", Regexp::IGNORECASE)
        markers    = Regexp.new("\\b(#{expressions['universal'].join('|')})\\b", Regexp::IGNORECASE)
        exceptions = Regexp.new("\\b(#{expressions['exceptions'].join('|')})\\b", Regexp::IGNORECASE)

        the = (text =~ markers || text =~ starts || text =~ ends) && !text.match?(exceptions) ? 'the ' : ''

        "#{the}#{text}"
      end
    end
  end
end
