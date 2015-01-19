module P4
  module Chips
    class TransactionResult < Transaction
      validates :game_id, presence: true
    end
  end
end
