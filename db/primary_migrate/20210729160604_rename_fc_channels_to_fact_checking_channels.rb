# frozen_string_literal: true

class RenameFcChannelsToFactCheckingChannels < ActiveRecord::Migration[6.0]
  def change
    rename_table :fc_channels, :fact_checking_channels
  end
end
