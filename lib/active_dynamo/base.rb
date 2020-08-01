require 'active_dynamo/queries'
require 'active_dynamo/persistence'

module ActiveDynamo
  class Base
    include Queries
    include Persistence

    class << self
      def table(options = {})
        @@table_name = options.fetch(:name, snake_name)
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
  end
end
