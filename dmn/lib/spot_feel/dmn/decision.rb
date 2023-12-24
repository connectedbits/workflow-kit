# frozen_string_literal: true

module SpotFeel
  module Dmn
    class Decision
      attr_accessor :id, :name, :decision_table, :required_decision_ids, :variable_name, :literal_expression

      def initialize(id:, name:, decision_table: nil, required_decision_ids: [], variable_name: nil, literal_expression: nil)
        @id = id
        @name = name
        @decision_table = decision_table
        @required_decision_ids = required_decision_ids
        @variable_name = variable_name
        @literal_expression = literal_expression
      end

      #
      # Parses a DMN XML document and returns an array of Decision objects
      #
      # @param String the DMN XML document
      # @return [Decision] an array of Decision objects
      #
      def self.decisions_from_xml(xml)
        Array.wrap(Hash.from_xml(xml)["definitions"]["decision"]).map do |decision_xml|
          if decision_xml["decisionTable"]
            Decision.new(
              id: decision_xml["id"],
              name: decision_xml["name"],
              decision_table: DecisionTable.from_xml(decision_xml["decisionTable"]),
              required_decision_ids: Array.wrap(decision_xml["informationRequirement"]).map do |info_req|
                info_req["requiredDecision"] && info_req["requiredDecision"]["href"] ? info_req["requiredDecision"]["href"].delete("#") : nil
              end.compact,
            )
          elsif decision_xml["literalExpression"]
            Decision.new(
              id: decision_xml["id"],
              name: decision_xml["name"],
              variable_name: decision_xml["variable"]["name"],
              literal_expression: decision_xml["literalExpression"]["text"],
              required_decision_ids: Array.wrap(decision_xml["informationRequirement"]).map do |info_req|
                info_req["requiredDecision"] && info_req["requiredDecision"]["href"] ? info_req["requiredDecision"]["href"].delete("#") : nil
              end.compact,
            )
          end
        end
      end

      def literal_expression?
        !literal_expression.nil?
      end

      #
      # Evaluates a decision given a set of decisions and a context
      #
      # @param String the id of the decision to evaluate
      # @param [Decision] an array of Decision objects
      # @param Used in recursive calls to pass along which decisions have already been evaluated
      # @param Hash of context variables to use in evaluation
      # @param Boolean whether to print debug output
      # @return
      #   - nil if no rule matched,
      #   - a hash if hit policy is :first or :unique and a rule matched,
      #   - an array of hashes if hit policy is :collect or :rule_order and one or more rules matched
      #
      def self.decide(decision_id, decisions:, context: {}, already_evaluated_decisions: {})
        decision = decisions.find { |d| d.id == decision_id }
        raise Error, "Decision #{decision_id} not found" unless decision

        # Evaluate required decisions recursively
        decision.required_decision_ids.each do |required_decision_id|
          next if already_evaluated_decisions[required_decision_id]
          next if decisions.find { |d| d.id == required_decision_id }.nil?

          result = decide(required_decision_id, decisions:, context:)

          context.merge!(result) if result.is_a?(Hash)

          already_evaluated_decisions[required_decision_id] = true
        end

        decision.decide(context)
      end

      def decide(context = {})
        # If it's a literal decision, just evaluate the expression and return the result
        return HashWithIndifferentAccess.new.tap do |result|
          result[variable_name] = SpotFeel.eval(literal_expression, context:)
        end if literal_expression?

        # It's a decision table, evaluate it
        output_values = []

        # Evaluate all inputs
        input_values = decision_table.inputs.map do |input|
          SpotFeel.eval(input.expression, context:)
        end

        decision_table.rules.each do |rule|
          # Test all input entries
          test_results = []
          rule.input_entries.each_with_index do |input_entry, index|
            test_results.push test_input_entry(input_values[index], input_entry, context)
          end

          # If all input entries passed, we have a match 
          if test_results.all?
            output_value = HashWithIndifferentAccess.new
            decision_table.outputs.each_with_index do |output, index|
              output_value[output.name] = SpotFeel.eval(rule.output_entries[index].expression, context:)
              val = SpotFeel.eval(rule.output_entries[index].expression, context:)
              nested_hash_value(output_value, output.name, val)
            end

            return output_value if decision_table.hit_policy == :first || decision_table.hit_policy == :unique

            output_values << output_value
          end
        end

        output_values.empty? ? nil : output_values
      end

      def test_input_entry(input_value, input_entry, context = {})
        return true if input_entry.test.nil? || input_entry.test == '-'
        return SpotFeel.test(input_value, input_entry.test, context: context)
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
