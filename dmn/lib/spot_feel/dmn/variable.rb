# frozen_string_literal: true

module SpotFeel
  module Dmn
    class Variable
      attr_reader :id, :name, :type_ref

      def self.from_json(json)
        Variable.new(id: json[:id], name: json[:name], type_ref: json[:type_ref])
      end

      def initialize(id:, name:, type_ref:)
        @id = id
        @name = name
        @type_ref = type_ref
      end

      def as_json
        {
          id: id,
          name: name,
          type_ref: type_ref,
        }
      end
    end
  end
end
