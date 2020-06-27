module ActiveDynamo
  class Base
    class << self
      def table(options = {})
        @@table_name = options.fetch(:name, name)
        @@key        = options.fetch(:key, nil)
        @@db_conn    = options.fetch(:db_conn, Aws::DynamoDB::Client.new)
      end

      def attributes(*attrs)
        @@attrs = attrs
        attr_reader *@@attrs

        define_method(:initialize) do |**args|
          @@attrs.each do |name|
            _value = args[name]
            instance_variable_set("@#{name}", _value)
          end
        end
      end

      def all
        @@db_conn.scan({ table_name: @@table_name }).items.map do |item|
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
        obj_hash = @@db_conn
          .get_item({ table_name: @@table_name, key: key_value }).item
          .transform_keys(&:to_sym)

        obj = new(obj_hash)
        obj.send(:update_key, key_value.keys)
        obj
      end

      def create(**args)
        obj = new(**args)
        obj.save
        obj
      end

      def delete(**key_value)
        @@db_conn.delete_item({ table_name: @@table_name, key: key_value})
      end
    end

    def save
      @@db_conn.put_item({ table_name: @@table_name, item: self.attributes })
    end

    def update(**args)
      updated_attrs = @@db_conn.update_item({
        table_name: @@table_name,
        key: self.key_attributes,
        update_expression: update__update_expression(args),
        expression_attribute_values: update__expression_attribute_values(args),
        return_values: "UPDATED_NEW"
      }).attributes

      updated_attrs.each do |key, value|
        self.instance_variable_set("@#{key}", value)
      end

      self
    end

    def attributes
      @@attrs.inject({}) do |h, attr|
        h.update(attr => self.instance_variable_get("@#{attr}"))
      end
    end

    def key_attributes
      self.attributes.slice(*@@key)
    end

    private

    def update_key(keys)
      @@key ||= keys
    end

    def update__update_expression(args)
      args.each_with_index.map do |(key, value), index|
        "#{key} = :#{key}#{index}"
      end.join(", ").prepend("SET ")
    end

    def update__expression_attribute_values(args)
      args.each_with_index.inject({}) do |expr, ((key, value), index)|
        expr.update(":#{key}#{index}" => value)
      end
    end
  end
end
