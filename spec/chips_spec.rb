require 'spec_helper'

describe P4::Chips do
  it 'should be a module' do
    expect(P4::Chips.class).to eql Module
  end

  let(:p1) { P4::Chips::TestUser.find_or_create_by_name 'jane@gmail.com' }
  let(:p2) { P4::Chips::TestUser.find_or_create_by_name 'jess@gmail.com' }
  let(:p3) { P4::Chips::TestUser.find_or_create_by_name 'john@gmail.com' }

  it '.configure' do
    expect(p1.respond_to? :chips).to be true
  end

  it 'User#chips object should have certain public methods' do
    expect((p1.chips.methods - Object.instance_methods).sort).to \
      eq [:buy, :gain, :lose, :reserve]
  end

  it { should respond_to(:buy) }
  it { should respond_to(:configure) }
  it { should respond_to(:fix_game) }
  it { should respond_to(:game_results_valid?) }
  it { should respond_to(:reserve) }

  it '.fix_game should return hash and create Balance and Transaction objs' do
    p1.chips.buy(200) {}
    p2.chips.buy(200) {}
    p3.chips.buy(200) {}

    game_results = P4::Chips.fix_game 1234 do
      p1.chips.lose 150
      p2.chips.lose 50
      p3.chips.gain 200
    end

    actual_balances = P4::Chips::Balance.order(player_id: :asc).all.map do |b|
      { player_id: b.user_id, chips: b.qty }
    end
    expect(actual_balances).to eq \
      [{ player_id: p1.send(:id), chips: 50 },
       { player_id: p2.send(:id), chips: 150 },
       { player_id: p3.send(:id), chips: 400 }]

    expect(game_results.class).to eq Hash
    expect(game_results.keys.sort).to eq [:game_id, :players]
    expect(game_results[:game_id]).to eq 1234
    expect(game_results[:players].size).to eq 3
    expect(game_results[:players]).to eq \
      [{ player_id: p1.send(:id), chips: -150 },
       { player_id: p2.send(:id), chips: -50 },
       { player_id: p3.send(:id), chips: 200 }]

    # transactions
    trans = P4::Chips::Transaction.all
    expect(trans.size).to eq 6
    expect(trans.map do |t|
      [
        t.game_id,
        P4::Chips::TestUser.find(
          P4::Chips::Balance.find(t.balance_id).user_id
        ).name,
        t.type, t.qty
      ]
    end).to eq [
      [nil, 'jane@gmail.com', 'P4::Chips::TransactionTrade', 200],
      [nil, 'jess@gmail.com', 'P4::Chips::TransactionTrade', 200],
      [nil, 'john@gmail.com', 'P4::Chips::TransactionTrade', 200],
      [1234, 'jane@gmail.com', 'P4::Chips::TransactionResult', -150],
      [1234, 'jess@gmail.com', 'P4::Chips::TransactionResult', -50],
      [1234, 'john@gmail.com', 'P4::Chips::TransactionResult', 200]
    ]

    # balances
    balances = P4::Chips::Balance.all
    expect(balances.size).to eq 3
    expect(balances.map do |t|
      [P4::Chips::TestUser.find(t.user_id).name, t.qty]
    end).to eq [
      ['jane@gmail.com', 50],
      ['jess@gmail.com', 150],
      ['john@gmail.com', 400]
    ]
  end

  it '.game_results_valid?' do
    p1.chips.buy(500) {}
    p2.chips.buy(500) {}
    p3.chips.buy(500) {}

    P4::Chips.fix_game 1234 do
      p1.chips.lose 150
      p2.chips.lose 50
      p3.chips.gain 200
    end
    expect(P4::Chips.game_results_valid?).to be true

    P4::Chips.fix_game 1234 do
      p1.chips.lose 150
      p2.chips.lose 50
      p3.chips.gain 201
    end
    expect(P4::Chips.game_results_valid?).to be false
  end

  it '#reserve' do
    # start balances
    b = P4::Chips::Balance.find_or_create_by_user_id p1.id
    b.update_attribute :qty, 100

    b = P4::Chips::Balance.find_or_create_by_user_id p2.id
    b.update_attribute :qty, 1000

    expect(p1.chips.reserve 4321, 50).to eq true
    expect(p2.chips.reserve 4321, 50).to eq true
    expect(P4::Chips::Balance.all.map { |e| [e.user_id, e.qty] }).to eq [
      [p1.id,  50], [p2.id, 950]
    ]
    expect(p1.chips.reserve 3333, 51).to eq false
    expect(p1.chips.reserve 4321, 51).to eq false
    expect(p1.chips.reserve 4321, 50).to eq true
  end
end
