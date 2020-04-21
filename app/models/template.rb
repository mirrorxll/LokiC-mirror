# frozen_sting_literal: true

class Template < ApplicationRecord
  belongs_to :story_type

  before_create do
    self.body = '<p>HEADLINE:</p><p><br></p><p>TEASER:</p><p><br></p><p>BODY:</p><p><br></p>'
  end
end
