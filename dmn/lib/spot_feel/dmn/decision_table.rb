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

        input_values = inputs.map do |input|
          input.input_expression.evaluate(variables)
        end

        rules.each do |rule|
          results = rule.evaluate(input_values, variables)
          if results.all?
            output_value = rule.output_value(outputs, variables)
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
    end
  end
end
