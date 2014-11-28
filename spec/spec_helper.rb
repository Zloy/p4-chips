require 'p4/chips'
require 'pry-byebug'

RSpec.configure do |config|
  require 'p4/chips/test_user'

  config.before :all do
    db_connection_config = { adapter: 'sqlite3', database: 'db/test.sqlite3' }
    P4::Chips.configure P4::Chips::TestUser, :id, :chips, db_connection_config
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
