#require "p4/chips/version"

module P4
  module Chips
    def self.configure player_class, player_id_method, player_api_method
      player_class.send :define_method, player_api_method do
        Chips::Player.new(self.send player_id_method)
      end
    end

    def self.fix_game game_id
      @@game_results      = nil
      self.send :create_game_results, game_id
      yield
      self.send :fix_game_results
      @@game_results
    end

    # private

    def self.create_game_results game_id
      @@game_results = {game_id: game_id, players: []}
    end

    def self.fix_player player_id, chips
      previous_fix = @@game_results[:players].select{|e| e[:player_id] == player_id }.first

      if previous_fix.nil?
        @@game_results[:players]<< {player_id: player_id, chips: chips}
      else
        raise "Player with id==#{player_id} has already #{\
            previous_fix[:chips] > 0 ? 'gained' : 'lost'\
          } chips for game_id = #{@@game_results[:game_id]}"
      end
    end

    def self.fix_game_results
      # preform actions with @@game_results here
      @@game_results
    end

    private_class_method :create_game_results, :fix_player, :fix_game_results

    class Player
      def initialize player_id
        @player_id= player_id
      end

      def gain chips
        Chips.send :fix_player, @player_id, chips
      end

      def lose chips
        Chips.send :fix_player, @player_id, -chips
      end
    end
  end
end
