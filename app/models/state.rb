class State < ApplicationRecord
  def name
    "#{full_name} (#{short_name})"
  end
end
