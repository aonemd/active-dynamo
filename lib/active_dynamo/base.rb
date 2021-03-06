require 'active_dynamo/query'
require 'active_dynamo/persistence'

module ActiveDynamo
  class Base
    include Query
    include Persistence

    class << self
      def table(options = {})
        @@table_name    = options.fetch(:name, snake_name)
        @@partition_key = options.fetch(:partition_key, nil)
        @@sort_key      = options.fetch(:sort_key, nil)
        @@primary_key   = [@@partition_key, @@sort_key].compact
        @@db_conn       = options.fetch(:db_conn, Aws::DynamoDB::Client.new)

        class_variables.each do |var|
          define_singleton_method(var.to_s.delete('@')) do
            class_variable_get(var)
          end
        end
      end

      def attributes(**attrs)
        @@attr_types = attrs
        @@attrs      = attrs.keys
        attr_reader(*@@attrs)

        define_method(:initialize) do |**args|
          @@attrs.each do |name|
            _type_parser = method(@@attr_types.fetch(name).to_s)
            _value       = _type_parser.call(args[name])
            instance_variable_set("@#{name}", _value)
          end
        end

        define_singleton_method('attrs') do
          class_variable_get('@@attrs')
        end

        define_singleton_method('attr_types') do
          class_variable_get('@@attr_types')
        end
      end
    end

    def attributes
      @@attrs.inject({}) do |h, attr|
        h.update(attr => self.instance_variable_get("@#{attr}"))
      end
    end

    def primary_key_attributes
      self.attributes.slice(*@@primary_key)
    end

    private

    def update_primary_key(keys)
      @@primary_key ||= keys
    end
  end
end
