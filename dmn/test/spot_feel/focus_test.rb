# frozen_string_literal: true

require "test_helper"

module SpotFeel
  describe :focus do
    it "should evaluate a decision with a required decision" do
      decisions = SpotFeel.decisions_from_xml(fixture_source("test.dmn"))
      context = {
        input: {
          category: "E",
          reference_date: Date.new(2018, 01, 04),
          test_date: Date.new(2018, 01, 03),
        }
      }
      
      result = Dmn::Decision.decide('primary_decision', decisions:, context:)
      _(result[:output][:score]).must_equal(50)   
    end
  end
end
