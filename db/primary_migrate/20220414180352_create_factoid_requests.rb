class CreateFactoidRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :factoid_requests do |t|
      t.belongs_to :requester
      t.belongs_to :frequency
      t.belongs_to :priority
      t.belongs_to :status

      t.string :agency_id, limit: 36, index: true
      t.string :opportunity_id, limit: 36, index: true

      t.string :name, index: { unique: true }
      t.string :google_doc_sheet_link
      t.timestamps
    end
  end
end
