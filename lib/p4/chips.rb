require "p4/chips/version"
require "p4/chips/player"
require "hashie"

module P4
  module Chips
    def self.config
      @config ||= Hashie::Mash.new
    end

    def self.configure
      yield self.config
    end
  end
end
