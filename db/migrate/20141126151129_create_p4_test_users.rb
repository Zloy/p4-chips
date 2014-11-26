class CreateP4TestUsers < ActiveRecord::Migration
  def up
    create_table :p4_chips_test_users do |t|
      t.string :name, null: false
    end
  end
end
