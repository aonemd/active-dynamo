module ActiveDynamo
  module Persistence
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      def create(**args)
        obj = new(**args)
        obj.save
        obj
      end

      def destroy(**key_value)
        db_conn.delete_item({
          table_name: table_name,
          key: key_value
        })
      end
    end

    def save
      self.class.db_conn.put_item({
        table_name: self.class.table_name,
        item: self.attributes
      })
    end
  end
end
