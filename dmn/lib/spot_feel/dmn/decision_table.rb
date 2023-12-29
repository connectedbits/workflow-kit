# frozen_string_literal: true

module SpotFeel
  module Dmn
    class DecisionTable
      attr_reader :id, :hit_policy, :inputs, :outputs, :rules

      def self.from_json(json)
        inputs = Array.wrap(json[:input]).map { |input| Input.from_json(input) }
        outputs = Array.wrap(json[:output]).map { |output| Output.from_json(output) }
        rules = Array.wrap(json[:rule]).map { |rule| Rule.from_json(rule) }
        DecisionTable.new(id: json[:id], hit_policy: json[:hit_policy], inputs: inputs, outputs: outputs, rules: rules)
      end

      def initialize(id:, hit_policy:, inputs:, outputs:, rules:)
        @id = id
        @hit_policy = hit_policy&.downcase&.to_sym || :unique
        @inputs = inputs
        @outputs = outputs
        @rules = rules
      end

      def evaluate(variables = {})
        output_values = []

        # Evaluate all inputs
        input_values = inputs.map do |input|
          input.input_expression.evaluate(variables)
        end

        rules.each do |rule|
          # Test all input entries
          test_results = []
          rule.input_entries.each_with_index do |input_entry, index|
            test_results.push test_input_entry(input_values[index], input_entry, variables)
          end

          # If all input entries passed, we have a match
          if test_results.all?
            output_value = HashWithIndifferentAccess.new
            outputs.each_with_index do |output, index|
              val = rule.output_entries[index].evaluate(variables)
              nested_hash_value(output_value, output.name, val)
            end

            return output_value if hit_policy == :first || hit_policy == :unique

            output_values << output_value
          end
        end

        output_values.empty? ? nil : output_values
      end

      def as_json
        {
          id: id,
          hit_policy: hit_policy,
          inputs: inputs.map(&:as_json),
          outputs: outputs.map(&:as_json),
          rules: rules.map(&:as_json),
        }
      end

      private

      def test_input_entry(input_value, input_entry, variables = {})
        input_entry.test(input_value, variables)
      end

      def nested_hash_value(hash, key_string, value)
        keys = key_string.split('.')
        current = hash
        keys[0...-1].each do |key|
          current[key] ||= {}
          current = current[key]
        end
        current[keys.last] = value
        hash
      end
    end
  end
end
