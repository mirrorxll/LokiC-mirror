# frozen_string_literal: true

class Template < ApplicationRecord # :nodoc:
  belongs_to :story

  has_rich_text :text
end
