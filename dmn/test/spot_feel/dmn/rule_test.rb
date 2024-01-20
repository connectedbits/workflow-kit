# frozen_string_literal: true

require "test_helper"

module SpotFeel
  module Dmn
    describe Rule do

      describe :evaluate do
        describe :output_value do
          let(:outputs) {
            [
              Output.new(id: 1, label: "Greeting", name: "message.greeting", type_ref: "string"),
              Output.new(id: 1, label: "Name", name: "message.name", type_ref: "string"),
            ]
          }

          let(:output_entries) {
            [
              LiteralExpression.new(text: '"Bonjour"'),
              LiteralExpression.new(text: 'name'),
            ]
          }

          let(:rule) {
            Rule.new(
              id: "1",
              input_entries: [
                UnaryTests.new(text: "fr"),
                UnaryTests.new(text: "false"),
              ],
              output_entries: output_entries,
            )
          }

          let(:variables) {
            { "language": "fr", "formal": false, "name": "Eric" }
          }

          it "should return a hash with the output value" do
            result = rule.output_value(outputs, variables)
            _(result).must_equal({ "message" => { "greeting" => "Bonjour", "name" => "Eric" } })
          end

          describe :with_nil_output_entry do
            let(:output_entries) {
              [
                LiteralExpression.new(text: nil),
                LiteralExpression.new(text: 'name'),
              ]
            }

            it "should ignore the output entry" do
              rule.output_entries = output_entries
              result = rule.output_value(outputs, variables)
              _(result).must_equal({ "message" => { "name" => "Eric" } })
            end
          end

          describe :with_blank_output_entry do
            let(:output_entries) {
              [
                LiteralExpression.new(text: ''),
                LiteralExpression.new(text: 'name'),
              ]
            }

            it "should ignore the output entry" do
              rule.output_entries = output_entries
              result = rule.output_value(outputs, variables)
              _(result).must_equal({ "message" => { "name" => "Eric" } })
            end
          end

          describe :with_empty_literal_output_entry do
            let(:output_entries) {
              [
                LiteralExpression.new(text: '""'),
                LiteralExpression.new(text: 'name'),
              ]
            }

            it "should ignore the output entry" do
              rule.output_entries = output_entries
              result = rule.output_value(outputs, variables)
              _(result).must_equal({ "message" => { "greeting" => "", "name" => "Eric" } })
            end
          end
        end
      end
    end
  end
end
