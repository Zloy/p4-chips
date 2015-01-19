module P4
  module Chips
    class Player
      def initialize(player_id)
        @player_id = player_id
      end

      def gain(chips)
        Chips.send :fix_player, @player_id, chips.abs
      end

      def lose(chips)
        Chips.send :fix_player, @player_id, -chips.abs
      end

      def reserve(game_id, chips)
        Chips.send :reserve, game_id, @player_id, chips.abs
      end

      def buy(chips, &block)
        Chips.send :buy,  @player_id, chips.abs, &block
      end
    end
  end
end
