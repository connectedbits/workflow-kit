# frozen_string_literal: true

require "test_helper"

module SpotFeel
  module Dmn
    describe Decision do
      describe :simple do
        let(:decisions) { SpotFeel.decisions_from_xml(fixture_source("fine.dmn")) }

        describe :decide do
          it "should match on the correct rules" do
            # Rule 1
            result = SpotFeel.decide('fine', decisions: decisions, context: { violation: { type: "speed", actual_speed: 75, speed_limit: 65 } })
            _(result).must_equal({ "amount" => 500, "points" => 3 })

            # # Rule 2
            result = SpotFeel.decide('fine', decisions: decisions, context: { violation: { type: "speed", actual_speed: 100, speed_limit: 65 } })
            _(result).must_equal({ "amount" => 1000, "points" => 7 })

            # Rule 3
            result = SpotFeel.decide('fine', decisions: decisions, context: { violation: { type: "parking", actual_speed: 0, speed_limit: 0 } })
            _(result).must_equal({ "amount" => 100, "points" => 1 })

            # Rule 4
            result = SpotFeel.decide('fine', decisions: decisions, context: { violation: { type: "driving under the influence", actual_speed: 0, speed_limit: 0 } })
            _(result).must_equal({ "amount" => 1000, "points" => 5 })

            # No Match
            result = SpotFeel.decide('fine', decisions: decisions, context: { violation: { type: "no match", actual_speed: 0, speed_limit: 0 } })
            _(result).must_be_nil
          end
        end

        describe :decisions_from_xml do
          let(:decision) { decisions.first }

          it "returns an array of decisions" do
            _(decisions.size).must_equal(1)
          end

          it "must parse decision attributes" do
            _(decision.id).must_equal("fine")
            _(decision.name).must_equal("Fine")
            _(decision.decision_table).wont_be_nil
          end
        end
      end

      describe :dependent do
        let(:decisions) { SpotFeel.decisions_from_xml(fixture_source("dinner.dmn")) }

        describe :decide do
        end

        describe :decisions_from_xml do
          let(:decisions) { SpotFeel.decisions_from_xml(fixture_source("dinner.dmn")) }
          let(:dish_decision) { decisions.find { |d| d.id == "dish" } }
          let(:beverages_decision) { decisions.find { |d| d.id == "beverages" } }

          it "returns an array of decisions" do
            _(decisions.size).must_equal(2)
          end

          it "must parse decision attributes" do
            _(dish_decision.id).must_equal("dish")
            _(dish_decision.name).must_equal("Dish")
            _(dish_decision.decision_table).wont_be_nil

            _(beverages_decision.id).must_equal("beverages")
            _(beverages_decision.name).must_equal("Beverages")
            _(beverages_decision.decision_table).wont_be_nil

            _(beverages_decision.required_decision_ids).must_equal(["dish"])
          end
        end
      end
    end
  end
end
