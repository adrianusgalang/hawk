class CreateAlerts < ActiveRecord::Migration[5.2]
  def change
    create_table :alerts do |t|
      t.timestamps
      t.float :value
      t.boolean :is_upper
      t.integer :metric_id
      t.integer :exclude_status
      t.string :date
    end
  end
end
