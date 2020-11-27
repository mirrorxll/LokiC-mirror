class AddHomePageToPublications < ActiveRecord::Migration[6.0]
  def change
    add_column :publications, :home_page, :string, after: :name
  end
end
