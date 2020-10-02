require 'test_helper'
require 'models/account'

module ActiveDynamo
  class BaseTest < Minitest::Test
    def test_table_name_is_set
      assert_equal Account.table_name, 'account'
    end

    def test_table_attributes_are_set
      refute_empty Account.attrs
    end
  end
end
