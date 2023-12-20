# frozen_string_literal: true

module SpotFeel
  module Dmn
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
  end
end
