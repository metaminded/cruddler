class CreateCats < ActiveRecord::Migration
  def change
    create_table :cats do |t|
      t.string :name
      t.references :house

      t.timestamps
    end
    add_index :cats, :house_id
  end
end
