class AddColumn < ActiveRecord::Migration[5.1]
  def change
    add_column :metrics, :alert_if_null, :integer, limit: 1
    add_column :metrics, :tag_telegram, :string
    add_column :metrics, :microservice_calculation, :string
    add_column :metrics, :microservice_render_image, :string
    add_column :metrics, :image, :string
  end
end
