# frozen_string_literal: true

module MiniLokiC
  module DataMatching
    class NearestWord
      # it returns nil or String or Array (if only_one_winner is false)
      def self.nearest_word_from_list(wrong_word, list_of_good_words, only_one_winner = true, max_dist = 3)
        dl = DamerauLevenshtein
        h = {}
        min_dist = max_dist + 1
        list_of_good_words.each do |good_word|
          dist = dl.distance(wrong_word.downcase, good_word.downcase, 1, max_dist)
          min_dist = dist if dist < min_dist
          h[dist] = [] unless h[dist]
          h[dist] << good_word
        end
        # p min_dist
        if min_dist == max_dist + 1
          nil
        elsif only_one_winner
          h[min_dist].count > 1 ? nil : h[min_dist][0]
        else
          h[min_dist]
        end
      end

      # state - full name or abbreviation ('Illinois' or 'IL')
      def self.correct_city_name(wrong_city_name, state, max_dist)
        @cities = {} unless @cities
        unless @cities[state]
          route = C::Mysql.on(DB02, 'hle_resources')

          query = "select p.short_name from usa_administrative_division_places p
              join usa_administrative_division_states s on s.id = p.state_id
            where s.name = '#{state}' or s.short_name = '#{state}';"

          @cities[state] = route.query(query).to_a.map { |r| r['short_name'] }
          route.close if route
        end
        nearest_word_from_list(shortening_fix(lstrip_nonalpha(wrong_city_name)), @cities[state], true, max_dist)
      end

      # Remove all non alpha characters in the beginning of the word
      def self.lstrip_nonalpha(str)
        str.nil? ? str : str.gsub(/\A[\d_\W]+/, '')
      end

      # Substitute all short/full words as they are in usa_administrative_division_counties_places_matching
      def self.shortening_fix(str)
        str.nil? ? str : str.sub(/\bMt\.? /i, 'Mount ').sub(/\bFt\.? /i, 'Fort ').sub(/\bSt /i, 'St. ').sub(/\bSaint /i, 'St. ').sub(/^E\.? /i, 'East ').sub(/^W\.? /i, 'West ').sub(/^N\.? /i, 'North ').sub(/^S\.? /i, 'South ')
      end
    end
  end
end
