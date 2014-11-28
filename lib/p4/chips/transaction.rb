module P4
  module Chips
    class Transaction< ActiveRecord::Base
      validates :qty, numericality: { only_integer: true }

      belongs_to :balance
    end
  end
end
