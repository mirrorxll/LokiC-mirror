# frozen_string_literal: true

module Samples
  module AutoFeedbackGenerator
    module Rules # :nodoc:
      private

      def checking(text, lambda)
        if text.is_a?(Array)
          text.find { |txt| lambda.call(txt) }
        else
          lambda.call(text) ? text : false
        end
      end

      def capital_letters(sample)
        lambda = ->(txt) { txt.match?(/[A-Z]{4,}/) }
        sample.each do |part, text|
          txt = checking(text, lambda)
          return [part, txt] if txt
        end

        false
      end

      def single_digits(sample)
        lambda = ->(txt) { txt.match?(/(^[0-9]\s)|(\s[0-9]\s)|(\s[0-9]$)|(\s[0-9]\W\s)/) }
        sample.each do |part, text|
          txt = checking(text, lambda)
          return [part, txt] if txt
        end

        false
      end

      def dollar_with_cents(sample)
        lambda = ->(txt) { txt.match?(/((\$[\d,]+\.\d+)\s(?!thousand|million|billion|trillion)|(^\$[\d,]+\.\d+$))/) }
        sample.each do |part, text|
          txt = checking(text, lambda)
          return [part, txt] if txt
        end

        false
      end

      def percentage_with_sign(sample)
        lambda = ->(txt) { txt.match?(/\d+\s*%/) }
        sample.each do |part, text|
          next if part.eql?(:tables)

          txt = checking(text, lambda)
          return [part, txt] if txt
        end

        false
      end

      def headline_length(sample)
        [:headline, sample[:headline]] if sample[:headline].length > 120
      end

      def capitalized_single_letter(sample)
        lambda = ->(txt) { txt.match?(/\s[B-HJ-Z]\s/) }
        sample.each do |part, text|
          txt = checking(text, lambda)
          return [part, txt] if txt
        end

        false
      end

      def all_two_of(sample)
        lambda = ->(txt) { txt.match?(/all\s2\sof|all\stwo\sof/) }
        sample.each do |part, text|
          txt = checking(text, lambda)
          return [part, txt] if txt
        end

        false
      end

      def decimal_with_zero(sample)
        lambda = ->(txt) { txt.match?(/\d+\.\d*0\b/) }
        sample.each do |part, text|
          txt = checking(text, lambda)
          return [part, txt] if txt
        end

        false
      end

      def contractions(sample)
        lambda = lambda do |txt|
          @contractions.any? { |c| txt.match?(/\b#{c['contraction']}\b/i) }
        end
        sample.each do |part, text|
          txt = checking(text, lambda)
          return [part, txt] if txt
        end

        false
      end

      def state_abbreviations(sample)
        text_lambda = lambda do |txt|
          @states.any? { |s| txt.match?(/#{s['AP']}|\b#{s['USPS']}\b/) }
        end
        table_lambda = lambda do |txt|
          @states.any? { |s| txt.match?(/\b#{s['name']}\b/) }
        end

        sample.each do |part, text|
          check_lambda =
            if %i[headline teaser body table_titles].include?(part)
              text_lambda
            elsif part.eql?(:tables)
              table_lambda
            end

          txt = checking(text, check_lambda)
          return [part, txt] if txt
        end

        false
      end

      def other_address_abbreviations(sample)
        check_lambda = lambda do |txt|
          @addr_abbr.any? { |a| txt.match?(/\b#{a['abbr_name']}\b/) }
        end
        sample.each do |part, text|
          txt = checking(text, check_lambda)
          return [part, txt] if txt
        end

        false
      end

      def district_of_columbia(sample)
        @states.each do |s|
          return [:headline, sample[:headline]] if sample[:headline].match?(/#{s['name']}/i)
          return [:teaser, sample[:teaser]] if sample[:teaser].match?(/#{s['name']}/i)
        end

        false
      end

      def city_from_another_state(sample)
        @states.each do |state|
          return [:headline, sample[:headline]] if sample[:headline].match?(/,\s*#{state['name']}/i)
        end

        false
      end

      def comma_after_state_name(sample)
        @states.each do |state|
          return [:headline, sample[:headline]] if sample[:headline].match?(/,\s*#{state['name']}/i)

          body_row = sample[:body].index { |b| b.match?(/,\s*#{state['name']}/i) }
          return [:body, sample[:body][body_row]] if body_row
        end

        false
      end

      def st_ave_blvd_abbreviations(sample)
        lambda = ->(txt) { txt.match?(/(\bstreet\b|\bavenue\b|\bboulevard\b)/i) }
        sample.each do |part, text|
          txt = checking(text, lambda)
          return [part, txt] if txt
        end

        false
      end

      def correct_zip_code(sample)
        lambda = ->(txt) { txt.match?(/(^\d{5}\s)|(\s\d{5}\s)|(\s\d{5}$)|(\s\d{5}\W\s)/) }
        sample.each do |part, text|
          txt = checking(text, lambda)
          return [part, txt] if txt
        end

        false
      end

      def sentence_with_one(sample)
        lambda = ->(txt) { txt.match?(/\bone\b/i) }
        sample.each do |part, text|
          txt = checking(text, lambda)
          return [part, txt] if txt
        end

        false
      end

      def usage_verb_have_has(sample)
        [:teaser, sample[:teaser]] if sample[:teaser].match?(/\bhave\b|\bhas\b/i)
      end

      def usage_verb_is_are(sample)
        [:teaser, sample[:teaser]] if sample[:teaser].match?(/\bis\b|\bare\b/i)
      end

      def usage_verb_was_were(sample)
        [:teaser, sample[:teaser]] if sample[:teaser].match?(/\bwas\b|\bwere\b/i)
      end

      def more_one_dig_after_point(sample)
        lambda = ->(txt) { txt.match?(/\d+\.\d{2,}\b/) }
        sample.each do |part, text|
          txt = checking(text, lambda)
          return [part, txt] if txt
        end

        false
      end

      def negative_amount(sample)
        lambda = ->(txt) { txt.match?(/\$-\d/) }
        sample.each do |part, text|
          txt = checking(text, lambda)
          return [part, txt] if txt
        end

        false
      end

      def increase_over(sample)
        lambda = ->(txt) { txt.match?(/increase over/i) }
        sample.each do |part, text|
          txt = checking(text, lambda)
          return [part, txt] if txt
        end

        false
      end

      def decrease_over(sample)
        lambda = ->(txt) { txt.match?(/decrease over/i) }
        sample.each do |part, text|
          txt = checking(text, lambda)
          return [part, txt] if txt
        end

        false
      end

      def ordinal_numbers(sample)
        rank = /\d(th|st|nd|rd)|(first|second|third|fourth|fifth|sixth|seventh|eighth|ninth)/i
        return [:headline, sample[:headline]] if sample[:headline].match?(rank)
        return [:teaser, sample[:teaser]] if sample[:teaser].match?(rank)

        false
      end

      def the_locality_of(sample)
        lambda = ->(txt) { txt.match?(/the city of|the town of|the village of/i) }
        sample.each do |part, text|
          txt = checking(text, lambda)
          return [part, txt] if txt
        end

        false
      end

      def the_county_of(sample)
        lambda = ->(txt) { txt.match?(/the county of/i) }
        sample.each do |part, text|
          txt = checking(text, lambda)
          return [part, txt] if txt
        end

        false
      end

      def washington_in_headline(sample)
        if sample[:headline].match?(/Washington/i) && !sample[:headline].match?(/the state of Washington/i)
          [:headline, sample[:headline]]
        else
          false
        end
      end

      def new_york_in_headline(sample)
        if sample[:headline].match?(/New York/i) && !sample[:headline].match?(/New York state/i)
          [:headline, sample[:headline]]
        else
          false
        end
      end

      def number_with_comma(sample)
        lambda = ->(txt) { txt.match?(/\d{2,}/) }
        sample.each do |part, text|
          txt = checking(text, lambda)
          return [part, txt] if txt
        end

        false
      end
    end
  end
end
