# frozen_string_literal: true

module MiniLokiC
  module Population
    module Publications
      # connection to production PL database and
      # generation output to console
      class Base
        def initialize
          pl_user = MiniLokiC.read_ini['pl_user']

          @route = MiniLokiC::Connect::Mysql.on(
            PL_PROD_DB_HOST, 'jnswire_prod',
            pl_user['user'], pl_user['password']
          )
        end

        private

        def get(query, close_connection = true)
          publications = @route.query(query).to_a

          if publications.any?
            first_pub = publications.first
            client_names = publications.map { |pub| pub['client_name'] }.uniq

            puts "--\n\n"
            puts "organization id:    #{@org_id.to_s.green}" if @org_id
            puts "organization name:  #{first_pub['org_name'].green}\n" if first_pub['org_name']

            puts 'client(s):'
            client_names.each { |name| puts "  #{name}".green }

            puts "\npublication(s):"
            publications.each { |pub| puts "  #{pub['name']}".green }

            puts "\n--\n"
          end

          @route&.close if close_connection
          publications.each { |pub| pub.delete('org_name') }

          publications
        end
      end
    end
  end
end
