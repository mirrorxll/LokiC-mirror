class CreateTypeOfWorks < ActiveRecord::Migration[6.0]
  def change
    create_table :type_of_works do |t|
      t.string :name
    end
  end
end
