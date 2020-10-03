require_relative 'queries/query_generator'

module ActiveDynamo
  module Queries
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      def all
        db_conn.scan({ table_name: table_name }).items.map do |item|
          new(item.symbolize_keys)
        end
      end

      def where(args)
        query = QueryGenerator.new(self).call(args)

        db_conn.query(query).items.map do |item|
          new(item.symbolize_keys)
        end
      end

      def find(**key_value)
        obj_hash = db_conn
          .get_item({ table_name: table_name, key: key_value }).item
          .symbolize_keys

        obj = new(obj_hash)
        obj.send(:update_primary_key, key_value.keys)
        obj
      end
    end
  end
end
