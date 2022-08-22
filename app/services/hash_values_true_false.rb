# frozen_string_literal: true

class HashValuesTrueFalse
  def self.convert(hash)
    hash.each do |key, value|
      hash[key] =
        if value.respond_to?(:to_hash)
          convert(value)
        else
          !value.in?(['0', 0, nil, false])
        end
    end

    hash.to_hash
  end
end
