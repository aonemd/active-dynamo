require 'test_helper'
require 'models/account'

module ActiveDynamo
  class QueriesTest < Minitest::Test
    def test_where_query
      Account.where(no: 123)
    end
  end
end
