class CreateDateExcs < ActiveRecord::Migration[5.2]
  def change
    create_table :date_excs do |t|
      t.timestamps
      t.string :date
      t.float :value
      t.float :ratio
      t.string :time_unit
      t.string :redash_id
      t.text :note
    end
  end
end
