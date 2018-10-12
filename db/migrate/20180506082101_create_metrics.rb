class CreateMetrics < ActiveRecord::Migration[5.1]
  def change
    create_table :metrics, {id: false} do |t|
      t.integer :id, limit: 4, auto_increment: true, primary_key: true
      t.timestamps
      t.integer :redash_id
      t.string :redash_title
      t.string :time_column
      t.string :value_column
      t.integer :time_unit, limit: 1
      t.integer :value_type, limit: 1
      t.string :email
      t.float :upper_threshold
      t.float :lower_threshold
      t.string :result_id
      t.string :telegram_chanel
      t.string :group
      t.string :next_update
      t.integer :schedule, limit: 4
    end
  end
end
