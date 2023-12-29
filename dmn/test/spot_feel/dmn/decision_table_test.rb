# frozen_string_literal: true

require "test_helper"

module SpotFeel
  module Dmn
    describe DecisionTable do
      describe :evaluate do
        it "should evaluate decision with unique hit policy" do
          definitions = Definitions.from_xml(fixture_source("test_unique.dmn"))
          decision_table = definitions.decisions.first.decision_table
          variables = {
            input: {
              category: "B",
            },
          }
          result = decision_table.evaluate(variables)
          _(result).must_equal({ "message" => "Message 2" })
        end
      end

      it "should evaluate rule order hit policy" do
        definitions = Definitions.from_xml(fixture_source("test_rule_order.dmn"))
        decision_table = definitions.decisions.first.decision_table
        variables = {
          input: {
            category: "A",
          },
        }
        result = decision_table.evaluate(variables)
        _(result).must_equal([
          { "message" => "Message 1" },
          { "message" => "Message 3" },
          { "message" => "Message 4" },
          { "message" => "Message 5" },
        ])
      end

      it "should evaluate a decision with no matching rules" do
        definitions = Definitions.from_xml(fixture_source("test_no_matching_rules.dmn"))
        decision_table = definitions.decisions.first.decision_table
        variables = {
          input: {
            input_1: 1,
            input_2: 2,
          },
        }
        result =decision_table.evaluate(variables)
        _(result).must_be_nil
      end
    end
  end
end
