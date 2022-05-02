# frozen_string_literal: true

class TableLocation < ApplicationRecord
  belongs_to :parent, polymorphic: true
  belongs_to :host
  belongs_to :schema

  def full_name
    "#{host&.name}.#{schema&.name}.#{table_name}"
  end

  def host_name
    host&.name
  end

  def schema_name
    schema&.name
  end
end

