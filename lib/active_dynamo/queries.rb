module ActiveDynamo
  module Queries
    def all
      db_conn.scan({ table_name: table_name }).items.map do |item|
        new(item.symbolize_keys)
      end
    end

    def where(**key_value)
      _key   = key_value.keys.first
      _value = key_value.values.first

      self.all.select do |item|
        item.send(_key) == _value
      end
    end

    def find(**key_value)
      obj_hash = db_conn
        .get_item({ table_name: table_name, key: key_value }).item
        .transform_keys(&:to_sym)

      obj = new(obj_hash)
      obj.send(:update_key, key_value.keys)
      obj
    end
  end
end