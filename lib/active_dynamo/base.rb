require 'active_dynamo/queries'
require 'active_dynamo/persistence'

module ActiveDynamo
  class Base
    extend Queries

    include Persistence

    class << self
      def table(options = {})
        @@table_name = options.fetch(:name, name)
        @@key        = options.fetch(:key, nil)
        @@db_conn    = options.fetch(:db_conn, Aws::DynamoDB::Client.new)

        class_variables.each do |var|
          define_singleton_method(var.to_s.delete('@')) do
            class_variable_get(var)
          end
        end
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
