class CreateP4ChipsTransactions < ActiveRecord::Migration
  def up
    create_table :p4_chips_transactions do |t|
      t.references :balance, null: false
      t.references :game
      t.integer :qty, null: false
      t.string :type

      t.timestamps
    end
  end
end
