class CreateDateExcs < ActiveRecord::Migration[5.2]
  def change
    create_table :date_excs, {id: false} do |t|
      t.integer :id, limit: 4, auto_increment: true, primary_key: true
      t.timestamps
      t.string :date
      t.float :value
      t.float :ratio
      t.integer :time_unit, limit: 1
      t.string :redash_id
      t.text :note
    end
  end
end
