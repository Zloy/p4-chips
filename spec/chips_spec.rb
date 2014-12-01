require 'spec_helper'

describe P4::Chips do
  it "should be a module" do
    expect(P4::Chips.class).to eql Module
  end

  let(:p1){ P4::Chips::TestUser.find_or_create_by_name 'jane@gmail.com'}
  let(:p2){ P4::Chips::TestUser.find_or_create_by_name 'jess@gmail.com'}
  let(:p3){ P4::Chips::TestUser.find_or_create_by_name 'john@gmail.com'}

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

  it ".fix_game should return proper hash and create proper Balance and Transaction objects" do
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
    
    # transactions
    trans = P4::Chips::Transaction.all
    expect(trans.size).to eq 3
    expect(trans.map{|t| [
      t.game_id, 
      P4::Chips::TestUser.find(P4::Chips::Balance.find(t.balance_id).user_id).name, 
      t.type, t.qty]}).to eq [
        [1234, "jane@gmail.com", "P4::Chips::TransactionResult", -150], 
        [1234, "jess@gmail.com", "P4::Chips::TransactionResult", -50], 
        [1234, "john@gmail.com", "P4::Chips::TransactionResult", 200]
      ]

    # balances  
    balances = P4::Chips::Balance.all
    expect(balances.size).to eq 3
    expect(balances.map{|t| [
      P4::Chips::TestUser.find(t.user_id).name, t.qty]}).to eq [
        ["jane@gmail.com", -150], 
        ["jess@gmail.com", -50], 
        ["john@gmail.com", 200]
      ]

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
