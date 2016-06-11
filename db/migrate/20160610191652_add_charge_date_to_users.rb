class AddChargeDateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :charge_date, :datetime
  end
end
