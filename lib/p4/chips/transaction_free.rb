module P4
  module Chips
    class TransactionFree< Transaction
      validates :game_id, presence: true
    end
  end
end
