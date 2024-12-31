# frozen_string_literal: true

module SpotFeel
  module Dmn
    class InformationRequirement
      attr_reader :id, :required_input_id, :required_decision_id

      def self.from_json(json)
        required_input_id = json[:required_input][:href].delete_prefix("#") if json[:required_input]
        required_decision_id = json[:required_decision][:href].delete_prefix("#") if json[:required_decision]
        InformationRequirement.new(id: json[:id], required_input_id: required_input_id, required_decision_id: required_decision_id)
      end

      def initialize(id:, required_input_id:, required_decision_id:)
        @id = id
        @required_input_id = required_input_id
        @required_decision_id = required_decision_id
      end

      def as_json
        {
          id: id,
          required_decision_id: required_decision_id,
          required_input_id: required_input_id,
        }
      end
    end
  end
end
