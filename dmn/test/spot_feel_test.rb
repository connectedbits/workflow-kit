# frozen_string_literal: true

require "test_helper"

describe SpotFeel do
  it "should have a version number" do
    _(SpotFeel::VERSION).wont_be_nil
  end

  describe :smoke_tests do
    describe :expressions do
      it "should parse a simple expression" do
        _(SpotFeel.parse('42')).must_be_kind_of(SpotFeel::NumericLiteral)
      end
    end

    describe :unary_tests do
      it "input entry '42' should match the numeric value 42" do
        _(SpotFeel.test(42, '42')).must_equal true
        _(SpotFeel.test(41, '42')).must_equal false
      end

      it "input entry '< 42' should match a value less than 42" do
        _(SpotFeel.test(41, '< 42')).must_equal true
        _(SpotFeel.test(42, '< 42')).must_equal false
      end

      it "input entry '[41 .. 50]' should match a value between 41 and 50 (inclusive)" do
        _(SpotFeel.test(41, '[41 .. 50]')).must_equal true
        _(SpotFeel.test(40, '[41 .. 50]')).must_equal false
      end

      it "input entry '<10, >20' should match a value less than 10 or greater than 20" do
        _(SpotFeel.test(21, '<10, >20')).must_equal true
        _(SpotFeel.test(15, '<10, >20')).must_equal false
      end

      it "input entry '\"A\"' should match the string value \"A\"" do
        _(SpotFeel.test("A", '"A"')).must_equal true
        _(SpotFeel.test("B", '"A"')).must_equal false
      end

      it "input entry: '\"A\"', '\"B\"' matches the string value \"A\" or \"B\"" do
        _(SpotFeel.test("B", '"A", "B"')).must_equal true
        _(SpotFeel.test("A", '"A", "B"')).must_equal true
        _(SpotFeel.test("C", '"A", "B"')).must_equal false
      end

      it "input entry 'true' should match the boolean value true" do
        _(SpotFeel.test(true, 'true')).must_equal true
        _(SpotFeel.test(false, 'true')).must_equal false
        _(SpotFeel.test(3, 'true')).must_equal false
      end

      it "input entry '-' should match anything" do
        _(SpotFeel.test("ANYTHING", '-')).must_equal true
        _(SpotFeel.test(3, '-')).must_equal true
        _(SpotFeel.test(false, '-')).must_equal true
      end

      it "a nil input entry should match anything" do
        # BUG: Nil input entries are not handled correctly
        #_(SpotFeel.test(33, nil)).must_equal true
      end
  
      it "input entry 'null' should match the nil value" do
        _(SpotFeel.test(nil, 'null')).must_equal true
        _(SpotFeel.test(3, 'null')).must_equal false
      end

      it "input entry 'not(null)' should match any value other than nil" do
        _(SpotFeel.test("ANYTHING", 'not(null)')).must_equal true
        _(SpotFeel.test(nil, 'not(null)')).must_equal false
      end

      it "input entry 'property' should match the same value as the property (must be given in the context)" do
        _(SpotFeel.test(42, 'property', context: { property: 42 })).must_equal true
      end

      it "input entry 'object.property' should match the same value as the property of the object" do
        _(SpotFeel.test(42, 'object.property', context: { object: { property: 42 } })).must_equal true
      end

      it "input entry 'f(a)' should match the same value as the function evaluated with the property (function and property must be given in the context)" do
        # TODO: Function invocation needs to handle variable arguments correctly
        #_(SpotFeel.test(42, 'f(a)', context: { f: ->(a) { a == 42 }, a: 42 })).must_equal true
      end

      it "input entry 'limit - 10' should match the same value as the limit minus 10" do
        # TODO: Need to evaluate named variables in the context when doing arithmetic
        #_(SpotFeel.test(42, 'limit - 10', context: { limit: 52 })).must_equal true
      end

      it "input entry 'limit * 2' should match the same value as the limit times 2" do
        # TODO: Need to evaluate named variables in the context when doing arithmetic
        #_(SpotFeel.test(42, 'limit * 2', context: { limit: 21 })).must_equal true
      end

      it "input entry '[limit.upper, limit.lower]' should match a value between the value of two given properties of object limit" do
        # TODO: Need to evaluate named variables in the context when doing range comparisons
        # _(SpotFeel.test(42, '[limit.upper, limit.lower]', context: { limit: { upper: 50, lower: 40 } })).must_equal true
      end

      it "input entry 'date(\"1963-12-23\")' should match the date value 1963-12-23" do
        _(SpotFeel.test(Date.new(1963, 12, 23), 'date("1963-12-23")')).must_equal true
        _(SpotFeel.test(Date.new(1963, 12, 24), 'date("1963-12-23")')).must_equal false
      end

      it "input entry 'date(property)' should match the date which is defined by the value of the given property, the time if cropped to 00:00:00" do
        _(SpotFeel.test(Date.new(1963, 12, 23), 'date(property)', context: { property: Date.new(1963, 12, 23) })).must_equal true
      end

      it "input entry 'date and time(property)' should match the date and time which is defined by the value of the given property" do
        _(SpotFeel.test(DateTime.new(1963, 12, 23, 12, 34, 56), 'date and time(property)', context: { property: DateTime.new(1963, 12, 23, 12, 34, 56) })).must_equal true
      end

      it "input entry 'duration(d)' should match the duration specified by d, an ISO 8601 duration string like P3D for three days (duration is built-in either)" do
        _(SpotFeel.test(3.days, 'duration("P3D")')).must_equal true
      end

      it "input entry 'duration(d) * 2' should match twice the duration" do
        # TODO: Need to support duration arithmetic
        #_(SpotFeel.test(6.days, 'duration("P3D") * 2')).must_equal true
      end

      it "input entry 'duration(begin, end)' should match the duration between the specified begin and end date" do
        # TODO: Need to support duration ranges
        #_(SpotFeel.test(3.days, 'duration("1963-12-23", "1963-12-26")')).must_equal true
      end

      it "input entry 'date(begin) + duration(d)' should match the date that results by adding the given duration to the given date" do
        # TODO: Need to support duration arithmetic
        #_(SpotFeel.test(Date.new(1963, 12, 23), 'date("1963-12-23") + duration("P3D")')).must_equal true
      end

      it "input entry '< date(begin) + duration(d)' should match any date before the date that results by adding the given duration to the given date" do
        # TODO: Need to support duration arithmetic and comparison
        #_(SpotFeel.test(Date.new(1963, 12, 22), '< date("1963-12-23") + duration("P3D")')).must_equal true
      end
    end
  end
end
