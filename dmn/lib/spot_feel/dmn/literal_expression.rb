# frozen_string_literal: true

module SpotFeel
  module Dmn
    class LiteralExpression
      attr_reader :id, :text

      def self.from_json(json)
        LiteralExpression.new(id: json[:id], text: json[:text])
      end

      def initialize(id: nil, text:)
        @id = id
        @text = text
      end

      def tree
        @tree ||= SpotFeel::Parser.parse(text)
      end

      def valid?
        return false if text.blank?
        tree.present?
      end

      def evaluate(variables = {})
        tree.eval(functions.merge(variables))
      end

      def functions
        builtins = LiteralExpression.builtin_functions
        custom = (SpotFeel.config.functions || {})
        ActiveSupport::HashWithIndifferentAccess.new(builtins.merge(custom))
      end

      def named_functions
        # Initialize a set to hold the qualified names
        function_names = Set.new

        # Define a lambda for the recursive function
        walk_tree = lambda do |node|
          # If the node is a qualified name, add it to the set
          if node.is_a?(SpotFeel::FunctionInvocation)
            function_names << node.fn_name.text_value
          end

          # Recursively walk the child nodes
          node.elements&.each do |child|
            walk_tree.call(child)
          end
        end

        # Start walking the tree from the root
        walk_tree.call(tree)

        # Return the array of functions
        function_names.to_a
      end

      def named_variables
        # Initialize a set to hold the qualified names
        qualified_names = Set.new

        # Define a lambda for the recursive function
        walk_tree = lambda do |node|
          # If the node is a qualified name, add it to the set
          if node.is_a?(SpotFeel::QualifiedName)
            qualified_names << node.text_value
          end

          # Recursively walk the child nodes
          node.elements&.each do |child|
            walk_tree.call(child)
          end
        end

        # Start walking the tree from the root
        walk_tree.call(tree)

        # Return the array of qualified names
        qualified_names.to_a
      end

      def self.builtin_functions
        HashWithIndifferentAccess.new({
          # Conversion functions
          "string": ->(from) { from.to_s },
          "number": ->(from) { from.include?(".") ? from.to_f : from.to_i },
          # Boolean functions
          # "not": ->(value) { value == true ? false : true },
          "is defined": ->(value) { !value.nil? },
          "get or else": ->(value, default) { value.nil? ? default : value },
          # String functions
          "substring": ->(string, start, length) { string[start - 1, length] },
          "substring before": ->(string, match) { string.split(match).first },
          "substring after": ->(string, match) { string.split(match).last },
          "string length": ->(string) { string.length },
          "upper case": ->(string) { string.upcase },
          "lower case": -> (string) { string.downcase },
          "contains": ->(string, match) { string.include?(match) },
          "starts with": ->(string, match) { string.start_with?(match) },
          "ends with": ->(string, match) { string.end_with?(match) },
          "matches": ->(string, match) { string.match?(match) },
          "replace": ->(string, match, replacement) { string.gsub(match, replacement) },
          "split": ->(string, match) { string.split(match) },
          "strip": -> (string) { string.strip },
          "extract": -> (string, pattern) { string.match(pattern).captures },
          # Numeric functions
          "decimal": ->(n, scale) { n.round(scale) },
          "floor": ->(n) { n.floor },
          "ceiling": ->(n) { n.ceil },
          "round up": ->(n) { n.ceil },
          "round down": ->(n) { n.floor },
          "abs": ->(n) { n.abs },
          "modulo": ->(n, divisor) { n % divisor },
          "sqrt": ->(n) { Math.sqrt(n) },
          "log": ->(n) { Math.log(n) },
          "exp": ->(n) { Math.exp(n) },
          "odd": ->(n) { n.odd? },
          "even": ->(n) { n.even? },
          "random number": ->(n) { rand(n) },
          # List functions
          "list contains": ->(list, match) { list.include?(match) },
          "count": ->(list) { list.length },
          "min": ->(list) { list.min },
          "max": ->(list) { list.max },
          "sum": ->(list) { list.sum },
          "product": ->(list) { list.inject(:*) },
          "mean": ->(list) { list.sum / list.length },
          "median": ->(list) { list.sort[list.length / 2] },
          "stddev": ->(list) {
            mean = list.sum / list.length.to_f
            Math.sqrt(list.map { |n| (n - mean)**2 }.sum / list.length)
          },
          "mode": ->(list) { list.group_by(&:itself).values.max_by(&:size).first },
          "all": ->(list) { list.all? },
          "any": ->(list) { list.any? },
          "sublist": ->(list, start, length) { list[start - 1, length] },
          "append": ->(list, item) { list + [item] },
          "concatenate": ->(list1, list2) { list1 + list2 },
          "insert before": ->(list, position, item) { list.insert(position - 1, item) },
          "remove": ->(list, position) { list.delete_at(position - 1); list },
          "reverse": ->(list) { list.reverse },
          "index of": ->(list, match) { list.index(match) + 1 },
          "union": ->(list1, list2) { list1 | list2 },
          "distinct values": ->(list) { list.uniq },
          "duplicate values": ->(list) { list.select { |e| list.count(e) > 1 }.uniq },
          "flatten": ->(list) { list.flatten },
          "sort": ->(list) { list.sort },
          "string join": ->(list, separator) { list.join(separator) },
          # Context functions
          "get value": ->(context, name) { context[name] },
          "context put": ->(context, name, value) { context[name] = value; context },
          "context merge": ->(context1, context2) { context1.merge(context2) },
          "get entries": ->(context) { context.entries },
          # Temporal functions
          "now": ->() { Time.now },
          "today": ->() { Date.today },
          "day of week": ->(date) { date.wday },
          "day of year": ->(date) { date.yday },
          "week of year": ->(date) { date.cweek },
          "month of year": ->(date) { date.month },
        })
      end

      def as_json
        {
          id: id,
          text: text,
        }
      end
    end
  end
end
