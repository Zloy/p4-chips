require 'p4/chips'
require 'pry-byebug'

RSpec.configure do |config|
  require 'p4/chips/test_user'

  config.before :all do
    db_connection_config = { adapter: 'sqlite3', database: 'db/test.sqlite3' }
    ActiveRecord::Base.establish_connection db_connection_config

    P4::Chips.configure P4::Chips::TestUser, :id, :chips
  end

  require 'database_cleaner'
  DatabaseCleaner.strategy = :transaction

  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end
end

require 'coveralls'
Coveralls.wear!
