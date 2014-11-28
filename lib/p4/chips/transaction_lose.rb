module P4
  module Chips
    class TransactionLose< Transaction
      validates :game_id, presence: true
    end
  end
end
