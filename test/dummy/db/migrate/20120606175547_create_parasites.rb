class CreateParasites < ActiveRecord::Migration
  def change
    create_table :parasites do |t|
      t.string :name
      t.integer :legs
      t.references :cat

      t.timestamps
    end
    add_index :parasites, :cat_id
  end
end
