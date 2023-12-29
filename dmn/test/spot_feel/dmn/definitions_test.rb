# frozen_string_literal: true

require "test_helper"

module SpotFeel
  module Dmn
    describe Definitions do
      describe :from_xml do
        let(:xml) { fixture_source("test.dmn") }
        let(:definitions) { Definitions.from_xml(xml) }

        it "should parse definitions" do
          _(definitions).wont_be_nil
          _(definitions.execution_platform).must_equal("Camunda Cloud")
          _(definitions.execution_platform_version).wont_be_nil
          _(definitions.exporter).must_equal("Camunda Modeler")
          _(definitions.exporter_version).wont_be_nil
          _(definitions.id).must_equal("test")
          _(definitions.name).must_equal("Test")
          _(definitions.namespace).must_equal("http://camunda.org/schema/1.0/dmn")
          _(definitions.decisions.size).must_equal(2)
        end
      end

      describe :evaluate do
        it "should evaluate decisions with dependencies" do
          definitions = Definitions.from_xml(fixture_source("test.dmn"))
          variables = {
            input: {
              category: "E",
              reference_date: Date.new(2018, 01, 04),
              test_date: Date.new(2018, 01, 03),
            },
          }

          result = definitions.evaluate('primary_decision', variables:)
          _(result[:output][:score]).must_equal(50)

          variables[:input][:test_date] = Date.new(2018, 04, 04)
          result = definitions.evaluate('primary_decision', variables:)
          _(result[:output][:score]).must_equal(100)

          variables[:input][:test_date] = Date.new(2018, 04, 05)
          result = definitions.evaluate('primary_decision', variables:)
          _(result[:output][:score]).must_equal(0)
        end
      end
    end
  end
end
