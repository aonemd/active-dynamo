module ActiveDynamo
  module Persistence
    class Updater
      def initialize(initiator)
        @initiator = initiator
      end

      def call(**args)
        updated_attrs = @initiator.class.db_conn.update_item({
          table_name: @initiator.class.table_name,
          key: @initiator.primary_key_attributes,
          update_expression: update_expression(args),
          expression_attribute_values: expression_attribute_values(args),
          return_values: "UPDATED_NEW"
        }).attributes

        updated_attrs.each do |key, value|
          @initiator.instance_variable_set("@#{key}", value)
        end

        @initiator
      end

      private

      def update_expression(args)
        args.each_with_index.map do |(key, _), index|
          "#{key} = :#{key}#{index}"
        end.join(", ").prepend("SET ")
      end

      def expression_attribute_values(args)
        args.each_with_index.inject({}) do |expr, ((key, value), index)|
          expr.update(":#{key}#{index}" => value)
        end
      end
    end
  end
end
