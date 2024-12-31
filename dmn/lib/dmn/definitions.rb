# frozen_string_literal: true

module SpotFeel
  module Dmn
    class Definitions
      attr_reader :id, :name, :namespace, :exporter, :exporter_version, :execution_platform, :execution_platform_version
      attr_reader :decisions

      def self.from_xml(xml)
        XmlHasher.configure do |config|
          config.snakecase = true
          config.ignore_namespaces = true
          config.string_keys = false
        end
        json = XmlHasher.parse(xml)
        Definitions.from_json(json[:definitions])
      end

      def self.from_json(json)
        decisions = Array.wrap(json[:decision]).map { |decision| Decision.from_json(decision) }
        Definitions.new(id: json[:id], name: json[:name], namespace: json[:namespace], exporter: json[:exporter], exporter_version: json[:exporter_version], execution_platform: json[:execution_platform], execution_platform_version: json[:execution_platform_version], decisions: decisions)
      end

      def initialize(id:, name:, namespace:, exporter:, exporter_version:, execution_platform:, execution_platform_version:, decisions:)
        @id = id
        @name = name
        @namespace = namespace
        @exporter = exporter
        @exporter_version = exporter_version
        @execution_platform = execution_platform
        @execution_platform_version = execution_platform_version
        @decisions = decisions
      end

      def evaluate(decision_id, variables: {}, already_evaluated_decisions: {})
        decision = decisions.find { |d| d.id == decision_id }
        raise EvaluationError, "Decision #{decision_id} not found" unless decision

        # Evaluate required decisions recursively
        decision.required_decision_ids&.each do |required_decision_id|
          next if already_evaluated_decisions[required_decision_id]
          next if decisions.find { |d| d.id == required_decision_id }.nil?

          result = evaluate(required_decision_id, variables:, already_evaluated_decisions:)

          variables.merge!(result) if result.is_a?(Hash)

          already_evaluated_decisions[required_decision_id] = true
        end

        decision.evaluate(variables)
      end

      def as_json
        {
          id: id,
          name: name,
          namespace: namespace,
          exporter: exporter,
          exporter_version: exporter_version,
          execution_platform: execution_platform,
          execution_platform_version: execution_platform_version,
          decisions: decisions.map(&:as_json),
        }
      end
    end
  end
end
