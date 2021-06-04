class RemoveMaintenanceTaskEntries < ActiveRecord::Migration[6.1]
  def change
    drop_table :maintenance_task
  end
end
