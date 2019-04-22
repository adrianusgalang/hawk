class StatusOnCheck < ActiveRecord::Migration[5.1]
  def change
    add_column :metrics, :on_check, :integer, limit: 1
  end
end