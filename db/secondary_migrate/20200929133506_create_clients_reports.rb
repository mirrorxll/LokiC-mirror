class CreateClientsReports < ActiveRecord::Migration[6.0]
  def change
    create_table :clients_reports do |t|
      t.string :name
    end
  end
end
