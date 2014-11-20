require 'spec_helper'

describe P4::Chips do
  it "should be a module" do
    expect(P4::Chips.class).to eql Module
  end

  before :all do
    class User
      attr_reader :email
      def initialize email
        @email = email
      end
    end

    P4::Chips.configure User, :email, :chips
  end

  let(:p1){ User.new 'jane@gmail.com'}
  let(:p2){ User.new 'jess@gmail.com'}
  let(:p3){ User.new 'john@gmail.com'}

  it ".configure" do
    expect(p1.respond_to? :chips).to be true
  end

  it "User#chips object should have certain public methods" do
    expect((p1.chips.methods - Object.instance_methods).sort).to eq [:gain, :lose]
  end

  it "Chips module should have certain public methods" do
    expect((P4::Chips.methods - Class.methods).sort).to eq [:configure, :fix_game]
  end

  it ".fix_game should do its stuff and return proper hash" do
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
      [{player_id:p1.send(:email), chips:-150}, 
       {player_id:p2.send(:email), chips:-50}, 
       {player_id:p3.send(:email), chips:200}]
  end
end
