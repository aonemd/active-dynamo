module ActiveDynamo
  module Queries
    class QueryGenerator
      def initialize(initiator)
        @initiator = initiator
      end

      def call(args)
        augmented_args = if args.is_a? String
                           tokenize_string_query(args).map(&:symbolize_keys)
                          else
                            args.reduce([]) do |arr, (k, v)|
                              arr << { key: k, value: v, operator: '=' }
                            end
                          end

        key_condition_expression_args = []
        filter_expression_args        = []
        expression_attribute_names    = {}
        expression_attribute_values   = {}

        augmented_args.each_with_index do |arg, index|
          key      = arg[:key].to_sym
          operator = arg[:operator] || '='

          key_alias   = "#key_#{key}_#{index}"
          expression_attribute_names.update(key_alias => key)

          unless operator == 'BETWEEN'
            value = arg[:value]
            value_alias = ":key_#{key}_#{index}_value"

            sub_expression = [key_alias, value_alias].join(" #{operator} ")
            expression_attribute_values.update(value_alias => value)
          else
            value1, value2 = arg[:value1], arg[:value2]

            value1_alias = ":key_#{key}_#{index}_value_1"
            value2_alias = ":key_#{key}_#{index}_value_2"

            sub_expression = [key_alias, [value1_alias, value2_alias].join(' AND ')].join(" #{operator} ")

            expression_attribute_values.update(value1_alias => value1)
            expression_attribute_values.update(value2_alias => value2)
          end

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

      def tokenize_string_query(query)
        Lexer.new(query).call()
      end

      class Lexer
        # S                  -> PARTION_EXPRESSION SORT_EXPRESSION FILTER_EXPRESSION $
        # PARTION_EXPRESSION -> partition_key = :value
        # SORT_EXPRESSION    -> 'and' sort_key = :value | E
        # FILTER_EXPRESSION  -> 'and' (SINGLE_EXPRESSION | DOUBLE_EXPRESSION) FILTER_EXPRESSION | E
        # SINGLE_EXPRESSION  -> key (=|<|>|<=|>=) :value
        # DOUBLE_EXPRESSION  -> key 'BETWEEN' :value1 'AND' :value2

        def initialize(query)
          @query  = query
          @tokens = []
        end

        def call
          grammar = [
            /(?<key>[\w\d_.-]+)\s*(?<op>BETWEEN)\s*(?<value1>[\w\d_.-]+)\s*AND\s*(?<value2>[\w\d_.-]+)/,
            /(?<key>[\w\d_.-]+)\s*(?<op>(>=|<=|>|<))\s*(?<value>[\w\d_.-]+)/,
            /(?<key>[\w\d_.-]+)\s*(?<op>(=))\s*(?<value>[\w\d_.-]+)/
          ]

          @query.split('and').each do |sub_query|
            grammar.each do |g|
              if g.match(sub_query)
                @tokens << g.match(sub_query).named_captures
                break
              end
            end
          end

          @tokens
        end
      end
    end
  end
end
