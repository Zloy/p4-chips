require 'p4/chips/exceptions'
require 'p4/chips/transaction_reserve'
require 'p4/chips/transaction_result'
require 'p4/chips/transaction_trade'

module P4
  module Chips
    class Balance< ActiveRecord::Base
      validates :user_id, presence: true
      validates :qty, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

      has_many :trans,         :class_name => "P4::Chips::Transaction"
      has_many :trans_reserve, :class_name => "P4::Chips::TransactionReserve"
      has_many :trans_result,  :class_name => "P4::Chips::TransactionResult"
      has_many :trans_trade,   :class_name => "P4::Chips::TransactionTrade"

      def self.for_user_id user_id
        find_or_create_by_user_id(user_id)
      end

      def self.reserve game_id, user_id, qty
        user_balance = self.find_or_create_by_user_id user_id
        if user_balance.qty >= qty.abs
          transaction do
            user_balance.update_attributes qty: (user_balance.qty - qty.abs)
            user_balance.trans_reserve.create!(game_id: game_id, qty: qty.abs)
          end
          true
        else
          false
        end
      end

      def self.free game_id, user_id
        user_balance = self.find_or_create_by_user_id user_id
        qty = user_balance.trans_reserve.where(game_id: game_id).sum(:qty)
        transaction do
          raise P4::Chips::InsufficientFunds unless 
            user_balance.update_attributes qty: (user_balance.qty + qty)
          user_balance.trans_reserve.where(game_id: game_id).destroy_all
        end
      end

      def self.add game_id, user_id, qty
        user_balance = self.find_or_create_by_user_id user_id
        transaction do
          raise P4::Chips::InsufficientFunds unless 
            user_balance.update_attributes qty: (user_balance.qty + qty)
          user_balance.trans_result.create!(game_id: game_id, qty: qty)
        end
      end

      def self.trade user_id, qty, &block
        user_balance = self.find_or_create_by_user_id user_id
        transaction do
          raise P4::Chips::InsufficientFunds unless 
            user_balance.update_attributes qty: (user_balance.qty + qty)
          user_balance.trans_trade.create!(qty: qty)
          yield qty.abs
        end
      end
    end
  end
end
