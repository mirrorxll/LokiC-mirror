# frozen_string_literal: true

module Samples
  module AutoFeedbackGenerator
    module SampleToHash
      private

      def prepare(sample)
        parsed_html = Nokogiri::HTML.parse(sample.body)
        table_titles_raw = parsed_html.css("[style*='18px']").remove
        tables_raw = parsed_html.css("[style*='display:table-cell;']").remove
        body_raw = parsed_html.css('p').remove

        body = body_raw.each_with_object([]) do |p, obj|
          obj << ActionView::Base.full_sanitizer.sanitize(p.to_s)
        end

        table_titles = table_titles_raw.each_with_object([]) do |title, obj|
          obj << ActionView::Base.full_sanitizer.sanitize(title.to_s)
        end

        tables = tables_raw.each_with_object([]) do |table, obj|
          obj << ActionView::Base.full_sanitizer.sanitize(table.to_s)
        end

        body = body.map { |p| sanitize_text(p) }.compact
        table_titles = table_titles.map { |title| sanitize_text(title) }.compact
        tables = tables.map { |table| sanitize_table(table).strip }.compact

        {
          headline: sample.headline,
          teaser: sample.teaser,
          body: body,
          table_titles: table_titles,
          tables: tables
        }
      end

      def sanitize_text(str)
        str.match?(/^\s*$/) ? nil : str.gsub(/\s{2,}/, '').strip
      end

      def sanitize_table(str)
        str.gsub(/\n/, ' ').gsub(/\s{2,}/, ' ').strip
      end
    end
  end
end
