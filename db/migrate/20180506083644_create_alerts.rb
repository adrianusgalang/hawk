class CreateAlerts < ActiveRecord::Migration[5.1]
  def change
    create_table :alerts, {id: false} do |t|
      t.integer :id, limit: 4, auto_increment: true, primary_key: true
      t.timestamps
      t.float :value
      t.boolean :is_upper
      t.integer :metric_id
      t.integer :exclude_status, limit: 1
      t.string :date
    end
  end
end
