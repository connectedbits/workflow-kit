# frozen_string_literal: true

module SpotFeel
  module Dmn
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

      def validate
        [].tap do |errors|
          errors << "Inputs must be an array" unless inputs.is_a?(Array)
          errors << "Outputs must be an array" unless outputs.is_a?(Array)
          errors << "Rules must be an array" unless rules.is_a?(Array)
          errors << "Inputs must not be empty" if inputs.empty?
          errors << "Outputs must not be empty" if outputs.empty?
          errors << "Rules must not be empty" if rules.empty?
          errors << "Inputs must all be Input objects" unless inputs.all? { |i| i.is_a?(Input) }
          errors << "Outputs must all be Output objects" unless outputs.all? { |o| o.is_a?(Output) }
          errors << "Rules must all be Rule objects" unless rules.all? { |r| r.is_a?(Rule) }
          errors << "Rules must have an input entry for each input" if rules.input_entries.length != inputs.length
          errors << "Rules must have an output entry for each output" if rules.output_entries.length != outputs.length
        end
      end

      def valid?
        validate.empty?
      end
    end
  end
end
