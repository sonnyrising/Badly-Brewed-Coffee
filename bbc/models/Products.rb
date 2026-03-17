require 'sequel'
require 'sqlite3'
require_relative '../db/db'


class Products < Sequel::Model(:Products)

end