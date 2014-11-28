require 'p4/chips/transaction_reserve'
require 'p4/chips/transaction_free'
require 'p4/chips/transaction_gain'
require 'p4/chips/transaction_lose'

module P4
  module Chips
    class Balance< ActiveRecord::Base
      validates :user_id, presence: true
      validates :qty, numericality: { only_integer: true }

      has_many :trans,         :class_name => "P4::Chips::Transaction"
      has_many :trans_reserve, :class_name => "P4::Chips::TransactionReserve"
      has_many :trans_free,    :class_name => "P4::Chips::TransactionFree"
      has_many :trans_gain,    :class_name => "P4::Chips::TransactionGain"
      has_many :trans_lose,    :class_name => "P4::Chips::TransactionLose"

      def self.for_user_id user_id
        find_or_create_by_user_id(user_id)
      end

      def self.reserve game_id, user_id, qty
        user_balance = self.find_or_create_by_user_id user_id
        if user_balance.qty >= qty
          transaction do
            user_balance.update_attribute :qty, (user_balance.qty - qty)
            user_balance.trans_reserve.create!(game_id: game_id, qty: qty)
          end
          true
        else
          false
        end
      end

      def self.free game_id, user_id
        user_balance = self.find_or_create_by_user_id user_id
        qty = user_balance.trans_reserve.where(game_id: game_id).sum(:qty)
        qty -= user_balance.trans_free.where(game_id: game_id).sum(:qty)
        transaction do
          user_balance.update_attribute :qty, (user_balance.qty + qty)
          user_balance.trans_free.create!(game_id: game_id, qty: qty)
        end
      end

      def self.gain game_id, user_id, qty
        user_balance = self.find_or_create_by_user_id user_id
        transaction do
          user_balance.update_attribute :qty, (user_balance.qty + qty)
          user_balance.trans_gain.create!(game_id: game_id, qty: qty)
        end
      end

      def self.lose game_id, user_id, qty
        user_balance = self.find_or_create_by_user_id user_id
        transaction do
          user_balance.update_attribute :qty, (user_balance.qty - qty)
          user_balance.trans_lose.create!(game_id: game_id, qty: qty)
        end
      end
    end
  end
end
