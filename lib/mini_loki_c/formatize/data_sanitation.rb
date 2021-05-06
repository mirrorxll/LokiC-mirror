# frozen_string_literal: true

module MiniLokiC
  module Formatize
    # module for clean data
    module DataSanitation
      module_function

      def business_normalization(business)
        # Drop % to end for cases like this: "Enterprise Avenue Investor % Deloitte & Touche LLP"
        business = '' if business.nil?
        business = business.gsub(/\\'/, "'")
        business = business.gsub(/\s%\s.*/, '')
        business = business.gsub(/\bint\'l\b/i, 'International')
        business = business.gsub(%r{\s*\bD/?\.?B/?\.?A\b/?\.?\s*(.*)}i) do |m|
          m = m.sub(%r{\bD/?\.?B/?\.?A\b/?\.?\s*(.*)}i, '\1')
          m = business_normalization(m)
          " (doing business as #{m})"
        end
        business = business.sub(/\bColdwell Banker Residential Real Estate\s*-\s*(.*)\s*$/i, 'Coldwell Banker Residential Real Estate (\1)')
        business = business.gsub(/\s*\)/, ')').gsub(/\(\s*/, '(')
        business = business.gsub(/\s*\bvia (.*)/i, ' (via \1)')
        business = business.gsub(/\s*\(\bdoing business as\b\s*\)/i, ' (doing business as)')

        # delete parenthesis
        # we apparently don't want to do this universally anymore
        # business = business.gsub(/\([^\)]+(\)|\Z)/, '') unless business.match(/\(Truste?e?\)/)
        # dealing with semicolon to end
        business = business.gsub(/;\s+(#{BUSINESS_SUFFIXES})/i, ', \1').gsub(/\;.*\Z/, '')
        # replace ', Texas #nn' with ' No. nn'
        business = business.gsub(/\,\s+Texas\s+\#(\d+)/i, ' No. \1')
        # remove spaces around -
        business = business.gsub(/\s*\-\s*/, '-')
        business = normalize(business)
        # suffix formatting for businesses?  seems troublesome.
        # business = Name.format_suffixes(business)
        business = business.gsub(/(?:\sa\sTexas)?,?\s+\bLimited\s+Liabil?i?t?y?\s*C?o?m?p?a?n?y?\b/i, ' LLC').gsub(/,?\s+\bco(?:mpany)?\b\.{0,1}(?![^\,\s])/i, ' Co.').gsub(/(?:\,\s+a\s+#{STATES_FULL})?,?\s+\bcorp(?:oration)?\b\.{0,1}/i, ' Corp.').gsub(/,?\s+\bInc(?:orporated?)?\b\.{0,1}/i, ' Inc.').gsub(/(?:\,\s+a\s+#{STATES_FULL}\s+series\s*)?,?\s+\b(?:Limited?|Ltd)\b\.?/i, ' Ltd.').gsub(/\bBros\b\.{0,1}/i, 'Bros.').gsub(/,?\s+\bL\.{0,1}\s{0,1}L\.{0,1}\s{0,1}C\b\.{0,1}/i, ' LLC').gsub(/,?\s+\bL\.{0,1}\s{0,1}L\.{0,1}\s{0,1}P\b\.{0,1}/i, ' LLP').gsub(/,?\s+\bL\.*C\.*L\b\.{0,1}/i, ' LCL').gsub(/,?\s+\bL\.*P\b\.{0,1}/i, ' LP').gsub(/,?\s+\bL\.*P\.*C\b\.{0,1}/i, ' LPC').gsub(/,?\s+\bL\.*\s*C\b\.{0,1}/i, ' LC').gsub(/,?\s+\bP\.*C\b\.{0,1}/i, ' PC').gsub(/,?\s*(#{SUFFIXES})?,?\s*(#{SUFFIXES})?,?\s+\bP\.*A\b\.{0,1}(?:,\s+a\s+#{STATES_FULL}\s+pro?f?e?s?s?i?o?n?a?l?)?/i, ' PA').gsub(/,?\s+Professional\s+Associat?i?o?n?$|,?\s*\bP\.?A\b\.?\s*$/i, ' PA').gsub(/(?:\,\s+a\s+#{STATES_FULL})?\,?\s+N(?:on)?\.{0,1}\s*p(?:roi?fi?t)?\.{0,1}\s*C(?:o(?:mpany)?)?\.{0,1}\s*(?=(\s|\Z))/i, ' NPC')
        business = business.gsub(/(.*),?\s*\b(LLC\b|Inc\b\.|LP|LLP)(?!\s*-)(?! of\b)\s*(.*)/, '\1 \3 \2')
        business = business.gsub(/LLC\s*-\s*/, 'LLC - ')
        business = business.gsub(/\s*,\s*,?\s*/, ', ')
        business = business.gsub(/\s{2,}/, ' ')
        business = business.gsub(/\(U\.?S\.?A?\.?\)/i, '')
        # substitutes values in $business_acronyms hash for keys.
        BUSINESS_ACRONYMS_SUBS.each do |k, v|
          business = business.gsub(k, v)
        end
        # delete comma after 'jr.'
        business = business.gsub(/(?<=jr\.),/i, '')

        # .com, etc.
        business = domain_name(business)
        # dangling commas and a letter or two--deleted
        # business = business.gsub(/,(?:(.{0,3}|\s+#{$states_full}))\Z/, '')
        business = double_space_elimination(business)
        business #+ " BUSINESS"
      end

      def double_space_elimination(line)
        line.gsub!(/  /, ' ')
        line
      end

      def domain_name(value)
        value.gsub(/(?<=\w)\.(com|net|org|info|biz|mobi|asia|eu|xxx|us|co|mx|tw|gov|edu)\b/i, &:downcase)
      end

      def normalize(value)
        return '' if value.blank?

        value = value.strip
        value = value.gsub(/\\/, '')
        value = value.gsub(/(?<!\()\b([A-Za-z]+)\b(?!\)|[^\(]+\))/i, &:capitalize)
        value = value.gsub(/(?<=\')\bs\b/i, 's')
        value = value.gsub(/\bmac([A-Za-z]{2,})/i) { |m| 'Mac' + m.sub(/^mac/i, '').capitalize }
        value = value.gsub(/\bmc([A-Za-z]+)/i) { |m| 'Mc' + m.sub(/^mc/i, '').capitalize }
        value = value.gsub(/\b(of|and|or|the|is|at|an|as|in|to|from|for)\b/i, &:downcase) # UCLC exceptions
        value = value.gsub(/(?<!suite |No\. |Community |Apt\. )\ba\b(?!\.|\&|$)/i, &:downcase)
        value = value.gsub(/\b(westbound|eastbound|northbound|southbound)\b/i, &:downcase)
        value = value.gsub(/\b(iii?|iv|vii?i?|xv?ii?i?|xv|xiv|xix|xxi)\b|^([A-Z])/i, &:upcase)
        BUSINESS_ACRONYMS_SUBS.each do |k, v|
          value = value.gsub(k, v)
        end
        value
      end
    end
  end
end
