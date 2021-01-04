# frozen_string_literal: true

class StoryMixer
  def initialize; end

  # pubs_statistics = {pub_id_1: {'hd:0' => 10, 'hd:1' => 10...},
  #                    pub_id_2: {'hd:0' => 10, 'hd:1' => 11...}, ... }
  # hash - ready for inserting in staging table hash without `mixer_key` key
  # story_parts = {hd: [['"Header 1 #{a}"', 'a > 0'], ['"#{a} Header 2"', 'a > 1']],
  #                tr: [['"Teaser 1 #{a} and #{b}"', 'a > 0 && b > 0'], ['"Teaser 2 #{b} and #{a}"', 'a > 0 && b > 0']]}
  def self.get_key(pubs_statistics: {}, pub_id: nil, bind: nil, story_parts: {})
    pubs_statistics[pub_id] = {} if pubs_statistics[pub_id].nil?
    pub_statistics = pubs_statistics[pub_id]

    all_keys(story_parts).each do |key|
      pub_statistics[key] = 0 unless pub_statistics[key]
    end

    pub_statistics_dup = pub_statistics.sort_by { |_k, v| -v }.to_h

    res_key = next_key(pub_statistics_dup, story_parts, bind)

    pub_statistics[res_key] += 1
    res_key
  end

  def self.parse_key(variety_key: nil, bind: nil, story_parts: {})
    res = {}
    get_story_parts_by_key(variety_key, story_parts, true).each do |key, part|
      res[key] = bind.eval(part.first.to_s)
    rescue NameError => e
      raise "StoryMixer: \nUndefined local variable '#{e.message[/`(.+)'/, 1]}' (`#{part.first}`) in given binding: #{bind.local_variables}.\nCheck that you declared the variable correctly in your creation before `StoryMixer.parse_key()` call."
    end

    res
  end

  def self.get_pubs_statistics(staging, where = nil)
    db02 = C::Mysql.on(DB02, 'loki_storycreator')
    query = <<~SQL
      SELECT
        publication_id,
        variety_key,
        count(*) c
      FROM #{staging}
      #{"WHERE #{where}" if where}
      GROUP BY publication_id, variety_key;
    SQL
    raw = db02.query(query).to_a
    db02.close

    res = {}
    raw.group_by { |r| r['publication_id'] }.each do |pub, data|
      res[pub] = {}
      data.each do |key|
        res[pub][key['variety_key']] = key['c'] if key['variety_key']
      end
    end

    res
  end

  def self.all_keys(story_parts)
    parts = ['']
    story_parts.each.with_index do |part, index|
      arr = Array.new(part.last.size) { |i| "#{part.first}:#{i}" }
      parts = if index == 0
                arr
              else
                parts.product(arr).map { |x| x.join(',') }
              end
    end
    parts
  end

  def self.next_key(pub_statistics, story_parts, bind, exclude = [], history_key = {})
    key = pub_statistics.find { |k, v| !exclude.include?(k) && v == pub_statistics.reject { |k, _v| exclude.include?(k) }.values.min }.first

    get_story_parts_by_key(key, story_parts).each do |part|
      if part.nil?
        raise "StoryMixer: \nCan't find variety key '#{history_key[:key] || key}' in given story_parts. Maybe you edited list of story_parts. Remove rows with old key(s) from your staging table or repopulate old rows."
      end

      begin
        if bind.eval(part.last)
          key
        else
          next_key(pub_statistics, story_parts, bind, exclude << key, history_key)
        end
      rescue NameError => e
        raise "StoryMixer: \nUndefined local variable '#{e.message[/`(.+)'/, 1]}' (`#{part.last}`) in given binding: #{bind.local_variables}.\nCheck that you declared the variable correctly in your population before `StoryMixer.get_key()` call."
      end
    end

    history_key[:key] = key unless exclude.include?(key)
    history_key[:key] || key
  end

  def self.get_story_parts_by_key(key, story_parts, parse = false)
    res = parse ? {} : []
    key.split(',').each do |s|
      k, v = s.split(':')
      n = story_parts[k.to_sym][v.to_i]
      if parse
        res[k.to_sym] = n
      else
        res << n
      end
    end
    res
  end
end
