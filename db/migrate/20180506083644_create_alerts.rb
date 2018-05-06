class CreateAlerts < ActiveRecord::Migration[5.2]
  def change
    create_table :alerts do |t|
      t.timestamps
      t.float :value 
      t.boolean :is_upper
      t.references(:metric, foreign_key: true, index: true)
    end
  end
end
