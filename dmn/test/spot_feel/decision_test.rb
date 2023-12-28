# frozen_string_literal: true

require "test_helper"

module SpotFeel
  describe Decision do

    describe :decisions_from_xml do
      describe :dependent_decisions do
        let(:decisions) { Decision.decisions_from_xml(fixture_source("test.dmn")) }
        let(:primary_decision) { decisions.find { |d| d.id == "primary_decision" } }
        let(:dependent_decision) { decisions.find { |d| d.id == "dependent_decision" } }

        it "returns an array of decisions" do
          _(decisions.size).must_equal(2)
          _(primary_decision).wont_be_nil
          _(dependent_decision).wont_be_nil
        end

        it "must parse decision attributes" do
            _(primary_decision.name).must_equal("Primary Decision")
            _(primary_decision.decision_table).wont_be_nil
            _(dependent_decision.name).must_equal("Dependent Decision")
            _(dependent_decision.decision_table).wont_be_nil
        end
      end

      describe :literal_expression do
        let(:decisions) { Decision.decisions_from_xml(fixture_source("test_literal_decision.dmn")) }
        let(:decision) { decisions.first }

        it "returns a literal decision" do
          _(decision).wont_be_nil
          _(decision.literal_expression?).must_equal(true)
        end
      end
    end

    describe :decide do
      it "should evaluate decisons" do
        decisions = Decision.decisions_from_xml(fixture_source("test.dmn"))
        variables = {
          input: {
            category: "E",
            reference_date: Date.new(2018, 01, 04),
          },
        }
        result = Decision.decide('dependent_decision', decisions:, variables:)
        _(result[:period_begin]).must_be_kind_of(Date)
        _(result[:period_begin]).must_equal(Date.new(2018, 01, 04))
        _(result[:period_duration]).must_be_kind_of(ActiveSupport::Duration)
        _(result[:period_duration].in_months).must_equal(3)
      end

      it "should evaluate a decision with no matching rules" do
        decisions = Decision.decisions_from_xml(fixture_source("test_no_matching_rules.dmn"))
        variables = {
          input: {
            input_1: 1,
            input_2: 2,
          },
        }
        result = Decision.decide('unique_decision', decisions:, variables:)
        _(result).must_be_nil
      end

      it "should evaluate a decision with a required decision" do
        decisions = Decision.decisions_from_xml(fixture_source("test.dmn"))
        variables = {
          input: {
            category: "E",
            reference_date: Date.new(2018, 01, 04),
            test_date: Date.new(2018, 01, 03),
          }
        }

        result = Decision.decide('primary_decision', decisions:, variables:)
        _(result[:output][:score]).must_equal(50)

        variables[:input][:test_date] = Date.new(2018, 04, 04)
        result = Decision.decide('primary_decision', decisions:, variables:)
        _(result[:output][:score]).must_equal(100)

        variables[:input][:test_date] = Date.new(2018, 04, 05)
        result = Decision.decide('primary_decision', decisions:, variables:)
        _(result[:output][:score]).must_equal(0)
      end

      it "should evaluate decision with unique hit policy" do
        decisions = Decision.decisions_from_xml(fixture_source("test_unique.dmn"))
        variables = {
          input: { 
            category: "B",
          },
        }
        result = Decision.decide('unique_decision', decisions:, variables:)
        _(result).must_equal({ "message" => "Message 2" })
      end

      it "should evaluate rule order hit policy" do
        decisions = Decision.decisions_from_xml(fixture_source("test_rule_order.dmn"))
        variables = {
          input: {
            category: "A",
          },
        }
        result = Decision.decide('rule_order_decision', decisions:, variables:)
        _(result).must_equal([
          { "message" => "Message 1" },
          { "message" => "Message 3" },
          { "message" => "Message 4" },
          { "message" => "Message 5" },
        ])
      end

      it "should evaluate a literal expression" do
        decisions = Decision.decisions_from_xml(fixture_source("test_literal_decision.dmn"))
        variables = {
          age: 16,
        }
        result = Decision.decide('literal_decision', decisions:, variables:)
        _(result).must_equal({ "age_classification" => "minor" })
      end
    end
  end
end
