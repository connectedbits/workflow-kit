# frozen_string_literal: true

module SpotFeel
  module Dmn
    class Output
      attr_reader :id, :label, :name, :type_ref

      def self.from_json(json)
        Output.new(id: json[:id], label: json[:label], name: json[:name], type_ref: json[:type_ref])
      end

      def initialize(id:, label:, name:, type_ref:)
        @id = id
        @label = label
        @name = name
        @type_ref = type_ref
      end

      def as_json
        {
          id: id,
          label: label,
          name: name,
          type_ref: type_ref,
        }
      end
    end
  end
end
