class RemoveAuthorIdColumnFromClients < ActiveRecord::Migration[6.0]
  def change
    remove_column :clients, :author_id
  end
end
