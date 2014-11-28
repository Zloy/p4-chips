class CreateP4ChipsBalances < ActiveRecord::Migration
  def up
    create_table :p4_chips_balances do |t|
      t.references :user, null: false
      t.integer :qty, default: 0

      t.timestamps
    end
  end
end
