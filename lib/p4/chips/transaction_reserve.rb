module P4
  module Chips
    class TransactionReserve< Transaction
      validates :game_id, presence: true
    end
  end
end
