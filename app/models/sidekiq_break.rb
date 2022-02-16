class SidekiqBreak < ApplicationRecord
  belongs_to :breakable, polymorphic: true
end
