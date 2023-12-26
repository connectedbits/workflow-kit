# frozen_string_literal: true

require "test_helper"

module SpotFeel
  describe UnaryTests do
    it "should always pass with '-'" do
      _(UnaryTests.new('-').test(3)).must_equal true
      _(UnaryTests.new('-').test(2)).must_equal true
    end

    describe :comparison do
      it "should default to equality" do
        _(UnaryTests.new('3').test(3)).must_equal true
        _(UnaryTests.new('3').test(2)).must_equal false
      end

      it "should test unary operators" do
        _(UnaryTests.new('< 4').test(3)).must_equal true
        _(UnaryTests.new('< 2').test(2)).must_equal false
        _(UnaryTests.new('<= 3').test(3)).must_equal true
        _(UnaryTests.new('<= 1').test(2)).must_equal false
      end
    end

    describe :interval do
      it "should support open intervals" do
        _(UnaryTests.new('(2..4)').test(3)).must_equal true
        _(UnaryTests.new('(2..4)').test(5)).must_equal false
        _(UnaryTests.new('(2..4)').test(2)).must_equal false
        _(UnaryTests.new('(2..4)').test(4)).must_equal false
      end

      it "should support closed intervals" do
        _(UnaryTests.new('[2..4]').test(3)).must_equal true
        _(UnaryTests.new('[2..4]').test(2)).must_equal true
        _(UnaryTests.new('[2..4]').test(1)).must_equal false
      end
    end

    describe :disjunction do
      it "should test disjunction" do
        _(UnaryTests.new('2,3,4').test(3)).must_equal true
        _(UnaryTests.new('< 10, > 50').test(3)).must_equal true
      end
    end

    describe :negation do
      it "should test negation" do
        _(UnaryTests.new('not("valid")').test("valid")).must_equal false
        _(UnaryTests.new('not(2,3)').test(1)).must_equal true
      end
    end
  end
end