class CreateDogs < ActiveRecord::Migration
  def change
    create_table :dogs do |t|
      t.string :name
      t.integer :ref_id
      t.string :ref_type

      t.timestamps
    end
    add_index :dogs, :ref_id
    add_index :dogs, :ref_type
  end
end
