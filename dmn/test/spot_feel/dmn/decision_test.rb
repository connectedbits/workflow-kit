# frozen_string_literal: true

require "test_helper"

module SpotFeel
  module Dmn
    describe Decision do

      describe :evaluate do
        it "should evaluate literal expressions" do
          definitions = Definitions.from_xml(fixture_source("test_literal_decision.dmn"))
          decision = definitions.decisions.first
          variables = {
            age: 16,
          }
          result = decision.evaluate(variables)
          _(result).must_equal({ "age_classification" => "minor" })
        end
      end

      it "should evaluate decision tables" do
        definitions = Definitions.from_xml(fixture_source("test.dmn"))
        decision = definitions.decisions.last
        variables = {
          input: {
            category: "E",
            reference_date: Date.new(2018, 01, 04),
          },
        }
        result = decision.evaluate(variables)
        _(result[:period_begin]).must_be_kind_of(Date)
        _(result[:period_begin]).must_equal(Date.new(2018, 01, 04))
        _(result[:period_duration]).must_be_kind_of(ActiveSupport::Duration)
        _(result[:period_duration].in_months).must_equal(3)
      end
    end
  end
end
