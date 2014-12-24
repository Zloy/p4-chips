require "active_record"
require 'standalone_migrations'
require "p4/chips/version"
require "p4/chips/transaction"
require "p4/chips/player"

module P4
  module Chips
    def self.table_name_prefix
      'p4_chips_'
    end

    def self.configure player_class, player_id_method, player_api_method
      player_class.send :define_method, player_api_method do
        Chips::Player.new(self.send player_id_method)
      end
    end

    def self.fix_game game_id
      P4::Chips::Balance.transaction do
        @@game_results = self.send :create_game_results, game_id

        yield
        
        self.send :persist_game_results, @@game_results
        @@game_results
      end
    end

    # private

    def self.create_game_results game_id
      {game_id: game_id, players: []}
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

    def self.reserve game_id, player_id, chips
      Balance.reserve game_id, player_id, chips
    end

    def self.persist_game_results game_results
      game_id = game_results[:game_id]
      game_results[:players].each do |player_result|
        player_id = player_result[:player_id]
        chips     = player_result[:chips]
        P4::Chips::Balance.add game_id, player_id, chips
      end
    end

    def self.game_results_valid?
      @@game_results[:players].map{|e| e[:chips]}.inject(:+) == 0
    end

    private_class_method :create_game_results, :fix_player, :persist_game_results

  end
end
