# frozen_string_literal: true

module SpotFeel
  class Input
    attr_accessor :id, :label, :expression, :type_ref

    def initialize(id: nil, label: nil, expression: nil, type_ref: nil)
      @id = id
      @label = label
      @expression = expression
      @type_ref = type_ref
    end

    def self.from_xml(xml)
      Input.new(
        id: xml["id"],
        label: xml["label"],
        expression: xml["inputExpression"] ? xml["inputExpression"]["text"] : nil,
        type_ref: xml["inputExpression"] ? xml["inputExpression"]["typeRef"]&.downcase&.to_sym : nil,
      )
    end
  end

  class Output
    attr_accessor :id, :label, :name, :type_ref

    def initialize(id: nil, label: nil, name: nil, type_ref:)
      @id = id
      @label = label
      @name = name
      @type_ref = type_ref
    end

    def self.from_xml(xml)
      Output.new(
        id: xml["id"],
        name: xml["name"],
        label: xml["label"],
        type_ref: xml["typeRef"]&.downcase&.to_sym,
      )
    end
  end

  class InputEntry
    attr_accessor :id, :test

    def initialize(id: nil, test: nil)
      @id = id
      @test = test
    end

    def self.from_xml(xml)
      InputEntry.new(
        id: xml["id"],
        test: xml["text"],
      )
    end
  end

  class OutputEntry
    attr_accessor :id, :expression

    def initialize(id:, expression:)
      @id = id
      @expression = expression
    end

    def self.from_xml(xml)
      OutputEntry.new(
        id: xml["id"],
        expression: xml["text"],
      )
    end
  end

  class Rule
    attr_accessor :id, :input_entries, :output_entries

    def initialize(id: nil, input_entries: [], output_entries: [])
      @id = id
      @input_entries = input_entries
      @output_entries = output_entries
    end

    def self.from_xml(xml)
      Rule.new(
        id: xml["id"],
        input_entries: Array.wrap(xml["inputEntry"]).map { |input_entry_xml| InputEntry.from_xml(input_entry_xml) },
        output_entries: Array.wrap(xml["outputEntry"]).map { |output_entry_xml| OutputEntry.from_xml(output_entry_xml) },
      )
    end
  end

  class DecisionTable
    attr_accessor :inputs, :outputs, :rules, :hit_policy

    def initialize(inputs: [], outputs: [], rules: [], hit_policy: :unique)
      @inputs = inputs
      @outputs = outputs
      @rules = rules
      @hit_policy = hit_policy
    end

    def self.from_xml(xml)
      DecisionTable.new(
        hit_policy: xml["hitPolicy"]&.downcase&.to_sym || :unique,
        inputs: Array.wrap(xml["input"]).map { |input_xml| Input.from_xml(input_xml) },
        outputs: Array.wrap(xml["output"]).map { |output_xml| Output.from_xml(output_xml) },
        rules: Array.wrap(xml["rule"]).map { |rule_xml| Rule.from_xml(rule_xml) },
      )
    end
  end

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
      literal_expression.present?
    end

    #
    # Evaluates a decision given a set of decisions and variables
    #
    # @param String the id of the decision to evaluate
    # @param [Decision] an array of Decision objects
    # @param Used in recursive calls to pass along which decisions have already been evaluated
    # @param Hash of variables to use in evaluation
    # @param Boolean whether to print debug output
    # @return
    #   - nil if no rule matched,
    #   - a hash if hit policy is :first or :unique and a rule matched,
    #   - an array of hashes if hit policy is :collect or :rule_order and one or more rules matched
    #
    def self.decide(decision_id, decisions:, variables: {}, already_evaluated_decisions: {})
      decision = decisions.find { |d| d.id == decision_id }
      raise Error, "Decision #{decision_id} not found" unless decision

      # Evaluate required decisions recursively
      decision.required_decision_ids.each do |required_decision_id|
        next if already_evaluated_decisions[required_decision_id]
        next if decisions.find { |d| d.id == required_decision_id }.nil?

        result = decide(required_decision_id, decisions:, variables:)

        variables.merge!(result) if result.is_a?(Hash)

        already_evaluated_decisions[required_decision_id] = true
      end

      decision.decide(variables)
    end

    def decide(variables = {})
      # If it's a literal decision, just evaluate the expression and return the result
      return HashWithIndifferentAccess.new.tap do |result|
        result[variable_name] = Expression.new(literal_expression).eval(variables)
      end if literal_expression?

      # It's a decision table, evaluate it
      output_values = []

      # Evaluate all inputs
      input_values = decision_table.inputs.map do |input|
        SpotFeel.eval(input.expression, variables: variables)
      end

      decision_table.rules.each do |rule|
        # Test all input entries
        test_results = []
        rule.input_entries.each_with_index do |input_entry, index|
          test_results.push test_input_entry(input_values[index], input_entry, variables)
        end

        # If all input entries passed, we have a match 
        if test_results.all?
          output_value = HashWithIndifferentAccess.new
          decision_table.outputs.each_with_index do |output, index|
            output_value[output.name] = Expression.new(rule.output_entries[index].expression).eval(variables)
            val = Expression.new(rule.output_entries[index].expression).eval(variables)
            nested_hash_value(output_value, output.name, val)
          end

          return output_value if decision_table.hit_policy == :first || decision_table.hit_policy == :unique

          output_values << output_value
        end
      end

      output_values.empty? ? nil : output_values
    end

    private

    def test_input_entry(input_value, input_entry, context = {})
      return true if input_entry.test.nil? || input_entry.test == '-'
      return UnaryTests.new(input_entry.test).test(input_value, context)
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
