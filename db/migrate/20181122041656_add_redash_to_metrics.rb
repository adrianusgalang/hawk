class AddRedashToMetrics < ActiveRecord::Migration[5.1]
  def change
    add_column :metrics, :redash, :integer, limit: 4
    add_column :metrics, :on_off, :integer, limit: 1
    add_column :metrics, :last_update, :string
    add_column :metrics, :last_result, :integer, limit: 2
  end
end
