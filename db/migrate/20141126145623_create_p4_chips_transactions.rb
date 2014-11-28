class CreateP4ChipsTransactions < ActiveRecord::Migration
  def up
    # Yes, I know I should modify existing table, but now it's in my 
    # sole use, so I decided to force it
    create_table :p4_chips_transactions do |t|
      t.references :balance, null: false
      t.references :game
      t.integer :qty, null: false
      t.string  :type

      t.timestamps
    end
  end
end
