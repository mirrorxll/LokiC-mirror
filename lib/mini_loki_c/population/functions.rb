# frozen_string_literal: true

def get_journal_from_org_id(org_id, _environment, client_company_id = false)
  pl_route = MiniLokiC::Connect::Mysql.on(
    PL_PROD_DB_HOST, 'jnswire_prod',
    MiniLokiC.mysql_pl_replica_user,
    MiniLokiC.mysql_pl_replica_password
  )

  org_community_query = "select o.id org_id,o.name org_name,c.id publication_id,c.name publication_name,cc.id client_id,cc.name client_name from organizations o left join organization_communities oc on oc.organization_id = o.id left join communities c on c.id = oc.community_id left join client_companies cc on cc.id = c.client_company_id where organization_id = #{org_id} #{client_company_id ? "and c.client_company_id in (#{client_company_id})" : ''} group by c.id order by c.name"
  query_results = pl_route.query(org_community_query)

  publications = []
  if query_results.count.positive?
    query_results.each do |record|
      tmp_hash = {}
      tmp_hash['id'] = record['publication_id'].to_s
      tmp_hash['client_id'] = record['client_id']

      publications << tmp_hash
    end
  end

  pl_route.close
  publications
end

def insert_rules(hash)
  rule = ''
  hold = ''
  updates = ''
  hash.each do |key, value|
    value = 'null' if value.nil?
    rule = "#{rule}, `#{key}`"
    hold = "#{hold}, #{value}"
    updates = "#{updates}, `#{key}` = VALUES(`#{key}`)"
  end
  rule = rule.sub(/^\s*,\s*/, '')
  hold = hold.sub(/^\s*,\s*/, '')
  updates = updates.sub(/^\s*,\s*/, '')
  rule = '(' + rule + ') values(' + hold + ') on duplicate key update ' + updates
  rule
end

def graph_from_json(json)
  data = JSON.parse(json)
  table_headers =
    '<div style="display:table; border-style: solid; border-width: 1px;">'\
    '<div style="display:table-row; border-style: solid; border-width: 1px;">' +
    data.first.keys.map do |k|
      "<div style=\"display:table-cell; border-style: solid; border-width: 1px;\"><b><div style=\"padding:10px;text-align: center;\">#{k}</div></b></div>"
    end.join('') +
    '</div>'

  table_contents =
    data.map do |m|
      '<div style="display:table-row; border-style: solid; border-width: 1px;">' +
        m.values.map do |v|
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
    res = valid_encoding? ? self : ascii_escape(self)
    res.gsub(/\\/, '').gsub(%r{\\*(\'|\"|\*|\(|\)|\]|\[|/|\+|\\)}, '\\\\\1').strip
  end
end

Hash.class_eval do
  def escaped
    each { |key, value| self[key] = value ? value.is_a?(String) ? "'#{value.escaped}'" : value : "''" }
  end
end
