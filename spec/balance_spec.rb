require 'spec_helper'
require 'p4/chips/balance'

describe P4::Chips::Balance do
  before :each do
    # start balances
    b = P4::Chips::Balance.find_or_create_by_user_id 2
    b.update_attribute :qty, 100

    b = P4::Chips::Balance.find_or_create_by_user_id 3
    b.update_attribute :qty, 1_000
  end

  it '.reserve' do
    expect(P4::Chips::Balance.for_user_id(1).qty).to eq 0
    expect(P4::Chips::Balance.for_user_id(2).qty).to eq 100
    expect(P4::Chips::Balance.for_user_id(3).qty).to eq 1_000

    expect(P4::Chips::Balance.reserve 324_565, 1, 200).to be false
    expect(P4::Chips::Balance.reserve 324_565, 2, 200).to be false
    expect(P4::Chips::Balance.reserve 324_565, 3, 200).to be true

    expect(P4::Chips::Balance.for_user_id(1).qty).to eq 0
    expect(P4::Chips::Balance.for_user_id(2).qty).to eq 100
    expect(P4::Chips::Balance.for_user_id(3).qty).to eq 800

    expect(P4::Chips::Balance.reserve 304_565, 1, 30).to be false
    expect(P4::Chips::Balance.reserve 304_565, 2, 30).to be true
    expect(P4::Chips::Balance.reserve 304_565, 3, 30).to be true

    expect(P4::Chips::Balance.for_user_id(1).qty).to eq 0
    expect(P4::Chips::Balance.for_user_id(2).qty).to eq 70
    expect(P4::Chips::Balance.for_user_id(3).qty).to eq 770
  end

  it '.free' do
    expect(P4::Chips::Balance.reserve 304_565, 1, 30).to be false
    expect(P4::Chips::Balance.reserve 304_565, 2, 30).to be true
    expect(P4::Chips::Balance.reserve 304_565, 3, 30).to be true

    expect(P4::Chips::Balance.for_user_id(1).qty).to eq 0
    expect(P4::Chips::Balance.for_user_id(2).qty).to eq 70
    expect(P4::Chips::Balance.for_user_id(3).qty).to eq 970

    P4::Chips::Balance.free 304_565, 1
    P4::Chips::Balance.free 304_565, 2
    P4::Chips::Balance.free 304_565, 3

    expect(P4::Chips::Balance.for_user_id(1).qty).to eq 0
    expect(P4::Chips::Balance.for_user_id(2).qty).to eq 100
    expect(P4::Chips::Balance.for_user_id(3).qty).to eq 1_000
  end

  it '.add' do
    P4::Chips::Balance.add 304_565, 2, 700
    P4::Chips::Balance.add 304_565, 3, 60

    expect(P4::Chips::Balance.for_user_id(2).qty).to eq 800
    expect(P4::Chips::Balance.for_user_id(3).qty).to eq 1_060

    P4::Chips::Balance.add 304_565, 2, -700
    P4::Chips::Balance.add 304_565, 3, -120

    expect(P4::Chips::Balance.for_user_id(2).qty).to eq 100
    expect(P4::Chips::Balance.for_user_id(3).qty).to eq 940
  end

  it '.trade' do
    P4::Chips::Balance.trade 1, 30 do |qty|
      expect(qty).to eql 30
    end
    expect(P4::Chips::Balance.for_user_id(1).qty).to eq 30

    P4::Chips::Balance.trade 2, -100 do |qty|
      expect(qty).to eql 100
    end
    expect(P4::Chips::Balance.for_user_id(2).qty).to eq 0

    expect { P4::Chips::Balance.trade(2, -100) {} }.to \
      raise_error P4::Chips::InsufficientFunds
    expect(P4::Chips::Balance.for_user_id(2).qty).to eq 0
  end
end
