class CreateHouses < ActiveRecord::Migration
  def change
    create_table :houses do |t|
      t.string :name
      t.integer :number

      t.timestamps
    end
  end
end
