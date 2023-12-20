# frozen_string_literal: true

module SpotFeel
  module Dmn
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
  end
end
