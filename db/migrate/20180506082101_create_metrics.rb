class CreateMetrics < ActiveRecord::Migration[5.2]
  def change
    create_table :metrics do |t|
      t.timestamps
      t.integer :redash_id
      t.string :redash_title
      t.string :time_column
      t.string :value_column
      t.string :time_unit
      t.string :value_type
      t.string :email
      t.float :upper_threshold
      t.float :lower_threshold
      t.string :result_id
      t.string :telegram_chanel
    end
  end
end
