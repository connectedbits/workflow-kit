# frozen_string_literal: true

module SpotFeel
  module Dmn
    class Rule
      attr_reader :id, :input_entries, :output_entries, :description

      def self.from_json(json)
        input_entries = Array.wrap(json[:input_entry]).map { |input_entry| UnaryTests.from_json(input_entry) }
        output_entries = Array.wrap(json[:output_entry]).map { |output_entry| LiteralExpression.from_json(output_entry) }
        Rule.new(id: json[:id], input_entries:, output_entries:, description: json[:description])
      end

      def initialize(id:, input_entries:, output_entries:, description:)
        @id = id
        @input_entries = input_entries
        @output_entries = output_entries
        @description = description
      end

      def as_json
        {
          id: id,
          input_entries: input_entries.map(&:as_json),
          output_entries: output_entries.map(&:as_json),
          description: description,
        }
      end
    end
  end
end
