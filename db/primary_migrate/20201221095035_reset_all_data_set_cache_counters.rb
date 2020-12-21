class ResetAllDataSetCacheCounters < ActiveRecord::Migration[6.0]
  def up
    DataSet.all.each do |data_set|
      DataSet.reset_counters(data_set.id, :story_types)
    end
  end

  def down
    # no rollback needed
  end
end
