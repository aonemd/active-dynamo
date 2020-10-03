module ActiveDynamo
  module Queries
    class QueryGenerator
      def initialize(initiator)
        @initiator = initiator
      end

      def call(args)
        augemented_args = args.reduce([]) do |arr, (k, v)|
          arr << { key: k, value: v, operator: '=' }
        end

        key_condition_expression_args = []
        filter_expression_args        = []
        expression_attribute_names    = {}
        expression_attribute_values   = {}

        augemented_args.each_with_index do |arg, index|
          key      = arg[:key]
          value    = arg[:value]
          operator = arg[:operator] || '='

          key_alias   = "#key_#{key}_#{index}"
          value_alias = ":key_#{key}_#{index}_value"

          sub_expression = [key_alias, value_alias].join(" #{operator} ")

          expression_attribute_names.update(key_alias => key)
          expression_attribute_values.update(value_alias => value)

          if key == @initiator.partition_key || key == @initiator.sort_key
            key_condition_expression_args.push(sub_expression)
          else
            filter_expression_args.push(sub_expression)
          end
        end

        query = {
          table_name: @initiator.table_name,
          key_condition_expression: key_condition_expression_args.join(' and '),
          expression_attribute_names: expression_attribute_names,
          expression_attribute_values: expression_attribute_values
        }

        unless filter_expression_args.empty?
          query[:filter_expression] = filter_expression_args.join(' and ')
        end

        query
      end
    end
  end
end
