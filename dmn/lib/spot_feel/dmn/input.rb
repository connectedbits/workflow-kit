# frozen_string_literal: true

module SpotFeel
  module Dmn
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

      def eval(context: {})
        SpotFeel.eval(expression, context:)
      end
    end
  end
end
