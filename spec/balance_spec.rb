require 'spec_helper'
require 'p4/chips/balance'

describe P4::Chips::Balance do

  before :all do
    db_connection_config = { adapter: 'sqlite3', database: 'db/test.sqlite3' }
    P4::Chips.configure P4::Chips::TestUser, :id, :chips, db_connection_config
  end

  before :each do
    # start balances
    b = P4::Chips::Balance.find_or_create_by_user_id 2
    b.update_attribute :qty, 100

    b = P4::Chips::Balance.find_or_create_by_user_id 3
    b.update_attribute :qty, 1000
  end

  it ".reserve" do
    expect(P4::Chips::Balance.for_user_id(1).qty).to eq 0
    expect(P4::Chips::Balance.for_user_id(2).qty).to eq 100
    expect(P4::Chips::Balance.for_user_id(3).qty).to eq 1000

    expect(P4::Chips::Balance.reserve 324565, 1, 200).to be false
    expect(P4::Chips::Balance.reserve 324565, 2, 200).to be false
    expect(P4::Chips::Balance.reserve 324565, 3, 200).to be true

    expect(P4::Chips::Balance.for_user_id(1).qty).to eq 0
    expect(P4::Chips::Balance.for_user_id(2).qty).to eq 100
    expect(P4::Chips::Balance.for_user_id(3).qty).to eq 800

    expect(P4::Chips::Balance.reserve 304565, 1, 30).to be false
    expect(P4::Chips::Balance.reserve 304565, 2, 30).to be true
    expect(P4::Chips::Balance.reserve 304565, 3, 30).to be true

    expect(P4::Chips::Balance.for_user_id(1).qty).to eq 0
    expect(P4::Chips::Balance.for_user_id(2).qty).to eq 70
    expect(P4::Chips::Balance.for_user_id(3).qty).to eq 770
  end

  it ".free" do
    expect(P4::Chips::Balance.reserve 304565, 1, 30).to be false
    expect(P4::Chips::Balance.reserve 304565, 2, 30).to be true
    expect(P4::Chips::Balance.reserve 304565, 3, 30).to be true

    expect(P4::Chips::Balance.for_user_id(1).qty).to eq 0
    expect(P4::Chips::Balance.for_user_id(2).qty).to eq 70
    expect(P4::Chips::Balance.for_user_id(3).qty).to eq 970

    P4::Chips::Balance.free 304565, 1
    P4::Chips::Balance.free 304565, 2
    P4::Chips::Balance.free 304565, 3

    expect(P4::Chips::Balance.for_user_id(1).qty).to eq 0
    expect(P4::Chips::Balance.for_user_id(2).qty).to eq 100
    expect(P4::Chips::Balance.for_user_id(3).qty).to eq 1000
  end

  it ".gain" do
    P4::Chips::Balance.gain 304565, 2, 700
    P4::Chips::Balance.gain 304565, 3, 60

    expect(P4::Chips::Balance.for_user_id(2).qty).to eq 800
    expect(P4::Chips::Balance.for_user_id(3).qty).to eq 1060
  end

  it ".lose" do
    P4::Chips::Balance.lose 304565, 2, 700
    P4::Chips::Balance.lose 304565, 3, 60

    expect(P4::Chips::Balance.for_user_id(2).qty).to eq -600
    expect(P4::Chips::Balance.for_user_id(3).qty).to eq 940
  end
end
