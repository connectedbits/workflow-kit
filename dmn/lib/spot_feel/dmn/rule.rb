# frozen_string_literal: true

module SpotFeel
  module Dmn
    class Rule
      attr_accessor :id, :input_entries, :output_entries

      def initialize(id: nil, input_entries: [], output_entries: [])
        @id = id
        @input_entries = input_entries
        @output_entries = output_entries
      end

      #
      # Constructs a rule object from parsed XML
      #
      # @param Hash the parsed XML
      # @return a Rule object
      #
      def self.from_xml(xml)
        Rule.new(
          id: xml["id"],
          input_entries: Array.wrap(xml["inputEntry"]).map { |input_entry_xml| InputEntry.from_xml(input_entry_xml) },
          output_entries: Array.wrap(xml["outputEntry"]).map { |output_entry_xml| OutputEntry.from_xml(output_entry_xml) },
        )
      end

      def test(input_values:, context: {})
        input_values.map_with_index do |input_value, index|
          SpotFeel.test(input_value, input_entries[index].test, context: context)
        end.all? { |result| result == true }
      end
    end
  end
end
