def get_journal_from_org_id(org_id, environment, client_company_id = false)
  pl_user = read_ini['pl_user']
  pl_route = MiniLokiC::Connect::Mysql.on(environment =~ /^(prod|production)$/i ? PL_PROD_DB_HOST : PL_STAGE_DB_HOST, environment =~ /^(prod|production)$/i ? 'jnswire_prod' : 'jnswire_staging', pl_user['user'], pl_user['password'])
  puts pl_route
  # pl_route.query("use #{ environment =~ /^(prod|production)$/i ? 'jnswire_prod' : 'jnswire_staging'}")

  org_community_query = "select o.id org_id,o.name org_name,c.id publication_id,c.name publication_name,cc.id client_id,cc.name client_name from organizations o left join organization_communities oc on oc.organization_id = o.id left join communities c on c.id = oc.community_id left join client_companies cc on cc.id = c.client_company_id where organization_id = #{org_id} #{client_company_id ? "and c.client_company_id in (#{client_company_id})" : ""} group by c.id order by c.name"

  puts ""
  puts "get_journal_from_org_id: #{org_community_query}"

  query_results = pl_route.query(org_community_query)

  publications = []
  if query_results.count > 0
    puts "environment: #{environment} | org_id: #{org_id}  |  org_name: #{query_results.first['org_name']}"
    query_results.each do |record|
      tmp_hash = Hash.new
      tmp_hash['id'] = record['publication_id'].to_s
      tmp_hash['publication_name'] = record['publication_name'].to_s
      tmp_hash['client_id'] = record['client_id']
      tmp_hash['client_name'] = record['client_name']

      publications << tmp_hash
    end
  end
  puts publications
  puts ""
  pl_route.close if pl_route
  publications
end

def read_ini
  access_key = ''
  ini = File.read("#{ENV['HOME']}/ini/environment.ini")
  narf = ini.gsub(/\n/, ';').split(/\[([^\[]+)\];/).delete_if{|m| m[/^\s*$/]}
  na = narf.reject{|m| m[/;/]}
  rf = narf.reject{|m| !m[/;/]}
  narfnarf = Hash[na.zip(rf)]
  narfx3 = Hash.new
  narfnarf.each do |k, v|
    v = v.sub(/;*$/, '')
    narfx3[k] = Hash.new
    v.split(/;/).each do |m|
      narfx3[k][m.sub(/(.*)=>?.*/, '\1').strip] = m.sub(/.*=>?(.*)/, '\1').strip
    end
  end
  narfx3
end

def insert_rules(hash)
  puts 'insert_rules'
  rule = ''
  hold = ''
  updates = ''
  hash.each do |key, value|
    value = 'null' if value == nil
    rule = "#{rule}, `#{key}`"
    hold = "#{hold}, #{value}"
    updates = "#{updates}, `#{key}` = VALUES(`#{key}`)"
  end
  rule = rule.sub(/^\s*,\s*/, '')
  hold = hold.sub(/^\s*,\s*/, '')
  updates = updates.sub(/^\s*,\s*/, '')
  rule = '('+rule+') values('+hold+') on duplicate key update '+updates
  rule
end

def graph_from_json(json)
  data = JSON.parse(json)
  table_headers =
      '<div style="display:table; border-style: solid; border-width: 1px;">'\
  '<div style="display:table-row; border-style: solid; border-width: 1px;">' +
          data.first.keys.map  do |k|
            "<div style=\"display:table-cell; border-style: solid; border-width: 1px;\"><b><div style=\"padding:10px;text-align: center;\">#{k}</div></b></div>"
          end.join('') +
          '</div>'

  table_contents =
      data.map  do |m|
        '<div style="display:table-row; border-style: solid; border-width: 1px;">' +
            m.values.map  do |v|
              "<div style=\"display:table-cell; border-style: solid; border-width: 1px;\"><div style=\"padding:10px\">#{v}</div></div>"\
     end.join('') +
            '</div>'
      end.join('')

  table_terminus =
      '</div>'

  table = table_headers + table_contents + table_terminus
end

String.class_eval do
  def escaped
    res = self.valid_encoding? ? self : ascii_escape(self)
    res.gsub(/\\/, '').gsub(/\\*(\'|\"|\*|\(|\)|\]|\[|\/|\+|\\)/, '\\\\\1').strip
  end
end

Hash.class_eval do
  def escaped
    puts 'escaped'
    self.each{|key, value| self[key] = value ? value.is_a?(String) ? "'#{value.escaped}'" : value : "''"}
  end
end

def derive_options(*inputs)
  options = inputs.first
  p '...'
  p inputs
  if inputs[1].is_a?(Array)
    inputs[1] = inputs[1].first.split(/\s(?=--)/)
    p inputs
    inputs[1].each{|line| line.match(/--([^=]+)(?:=(.*)|\s*$)/){|m| options[m[1]] = (m[2] == nil or m[2] == '') ? 'enabled' : m[2]}}
  elsif inputs[1]
    puts 'error: non-array as second argument in options derivation'
  end
  ARGV.each do |line|
    line = line.gsub(/\n/, '\\n')
    line.match(/--([^=]+)(?:=(.*)|\s*$)/){|m|
      options[m[1]] = (m[2] == nil or m[2] == '') ? 'enabled' : m[2]
    }
  end
  if options['cl_args']
    options['cl_args'].split(/;/).each do |line|
      line.match(/--([^=]+)(?:=(.*)|\s*$)/){|m|
        options[m[1]] = (m[2] == nil or m[2] == '') ? 'enabled' : m[2]
      }
    end
  end
  options
end


