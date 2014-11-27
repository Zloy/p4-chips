class CreateP4ChipsTransactions < ActiveRecord::Migration
  def up
    create_table :p4_chips_transactions do |t|
      t.integer :user_id, null: false
      t.integer :game_id, null: false
      t.integer :qty
      t.float   :amount
      t.string  :type

      t.timestamps
    end
  end
end
