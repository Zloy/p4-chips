require 'spec_helper'
require 'yaml'
require 'standalone_migrations'
require 'pry-byebug'
require 'p4/chips/test_user'

describe P4::Chips do
  it "should be a module" do
    expect(P4::Chips.class).to eql Module
  end

  before :all do
    db_connection_config = { adapter: 'sqlite3', database: 'db/test.sqlite3' }
    P4::Chips.configure P4::Chips::TestUser, :id, :chips, db_connection_config
  end

  let(:p1){ P4::Chips::TestUser.create name: 'jane@gmail.com'}
  let(:p2){ P4::Chips::TestUser.create name: 'jess@gmail.com'}
  let(:p3){ P4::Chips::TestUser.create name: 'john@gmail.com'}

  it ".configure" do
    expect(p1.respond_to? :chips).to be true
  end

  it "User#chips object should have certain public methods" do
    expect((p1.chips.methods - Object.instance_methods).sort).to eq [:gain, :lose]
  end

  it "Chips module should have certain public methods" do
    expect((P4::Chips.methods - Class.methods).sort).to eq \
      [:configure, :fix_game, :game_results_valid?, :table_name_prefix]
  end

  it ".fix_game should return proper hash" do
    game_results = P4::Chips.fix_game 1234 do
      p1.chips.lose 150
      p2.chips.lose  50
      p3.chips.gain 200
    end
    expect(game_results.class).to eq Hash
    expect(game_results.keys.sort).to eq [:game_id, :players]
    expect(game_results[:game_id]).to eq 1234
    expect(game_results[:players].size).to eq 3
    expect(game_results[:players]).to eq \
      [{player_id:p1.send(:id), chips:-150}, 
       {player_id:p2.send(:id), chips:-50}, 
       {player_id:p3.send(:id), chips:200}]
  end

  it ".game_results_valid?" do
    game_results = P4::Chips.fix_game 1234 do
      p1.chips.lose 150
      p2.chips.lose  50
      p3.chips.gain 200
    end
    expect(P4::Chips.game_results_valid?).to be true

    game_results = P4::Chips.fix_game 1234 do
      p1.chips.lose 150
      p2.chips.lose  50
      p3.chips.gain 201
    end
    expect(P4::Chips.game_results_valid?).to be false
  end
end
