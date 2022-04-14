# frozen_string_literal: true

module MiniLokiC
  module DataMatching
    module_function

    def nearest_word_from_list(wrong_word, list_of_good_words, only_one_winner = true, max_dist = 3)
      NearestWord.from_list(wrong_word, list_of_good_words, only_one_winner, max_dist)
    end
  end
end
