# frozen_string_literal: true

require "test_helper"

module SpotFeel
  #
  # Builtin Functions
  #
  # https://docs.camunda.io/docs/components/modeler/feel/builtin-functions/feel-built-in-functions-introduction/
  #
  describe :builtin_functions do
    describe :conversion do
      it "should eval string" do
        _(Expression.new('string(123)').eval).must_equal "123"
      end

      it "should eval number" do
        _(Expression.new('number("123")').eval).must_equal 123
      end
    end

    describe :boolean do
      it "should eval is defined" do
        _(Expression.new('is defined("Hello world")').eval).must_equal true
        _(Expression.new('is defined(null)').eval).must_equal false
      end

      it "should eval get or else" do
        _(Expression.new('get or else("Hello world", "Goodbye world")').eval).must_equal "Hello world"
        _(Expression.new('get or else(null, "Goodbye world")').eval).must_equal "Goodbye world"
      end
    end

    describe :string do
      it "should eval substring" do
        _(Expression.new('substring("Hello world", 1, 4)').eval).must_equal "Hell"
      end

      it "should eval substring before" do
        _(Expression.new('substring before("Hello world", "world")').eval).must_equal "Hello "
      end

      it "should eval substring after" do
        _(Expression.new('substring after("Hello world", "Hello")').eval).must_equal " world"
      end

      it "should eval string length" do
        _(Expression.new('string length("Hello world")').eval).must_equal 11
      end

      it "should eval upper case" do
        _(Expression.new('upper case("Hello world")').eval).must_equal "HELLO WORLD"
      end

      it "should eval lower case" do
        _(Expression.new('lower case("Hello world")').eval).must_equal "hello world"
      end

      it "should eval contains" do
        _(Expression.new('contains("Hello world", "ello")').eval).must_equal true
      end

      it "should eval starts with" do
        _(Expression.new('starts with("Hello world", "Hello")').eval).must_equal true
      end

      it "should eval ends with" do
        _(Expression.new('ends with("Hello world", "world")').eval).must_equal true
      end

      it "should eval matches" do
        _(Expression.new('matches("Hello world", ".*world")').eval).must_equal true
      end

      it "should eval replace" do
        _(Expression.new('replace("Hello world", "world", "universe")').eval).must_equal "Hello universe"
      end

      it "should eval split" do
        _(Expression.new('split("Hello world", " ")').eval).must_equal ["Hello", "world"]
      end

      it "should eval strip" do
        _(Expression.new('strip(" Hello world ")').eval).must_equal "Hello world"
      end

      it "should eval extract" do
        _(Expression.new('extract("Hello world", "(Hello) (world)")').eval).must_equal ["Hello", "world"]
      end
    end

    describe :numeric do
      it "should eval decimal" do
        _(Expression.new('decimal(1.234, 2)').eval).must_equal 1.23
      end

      it "should eval floor" do
        _(Expression.new('floor(1.234)').eval).must_equal 1
      end

      it "should eval ceiling" do
        _(Expression.new('ceiling(1.234)').eval).must_equal 2
      end

      it "should eval round up" do
        _(Expression.new('round up(1.234)').eval).must_equal 2
      end

      it "should eval round down" do
        _(Expression.new('round down(1.234)').eval).must_equal 1
      end

      it "should eval abs" do
        _(Expression.new('abs(-1.234)').eval).must_equal 1.234
      end

      it "should eval modulo" do
        _(Expression.new('modulo(5, 2)').eval).must_equal 1
      end

      it "should eval sqrt" do
        _(Expression.new('sqrt(4)').eval).must_equal 2
      end

      it "should eval log" do
        _(Expression.new('log(10)').eval).must_equal 2.302585092994046
      end

      it "should eval exp" do
        _(Expression.new('exp(2)').eval).must_equal 7.38905609893065
      end

      it "should eval odd" do
        _(Expression.new('odd(1)').eval).must_equal true
        _(Expression.new('odd(2)').eval).must_equal false
      end

      it "should eval even" do
        _(Expression.new('even(1)').eval).must_equal false
        _(Expression.new('even(2)').eval).must_equal true
      end

      it "should eval random number" do
        _(Expression.new('random number(10)').eval).must_be :<, 10
      end
    end

    describe :list do
      it "should eval list contains" do
        _(Expression.new('list contains(["Hello", "world"], "world")').eval).must_equal true
      end

      it "should eval count" do
        _(Expression.new('count(["Hello", "world"])').eval).must_equal 2
      end

      it "should eval min" do
        _(Expression.new('min([1, 2, 3])').eval).must_equal 1
      end

      it "should eval max" do
        _(Expression.new('max([1, 2, 3])').eval).must_equal 3
      end

      it "should eval sum" do
        _(Expression.new('sum([1, 2, 3])').eval).must_equal 6
      end

      it "should eval product" do
        _(Expression.new('product([1, 2, 3])').eval).must_equal 6
      end

      it "should eval mean" do
        _(Expression.new('mean([1, 2, 3])').eval).must_equal 2
      end

      it "should eval median" do
        _(Expression.new('median([1, 2, 3])').eval).must_equal 2
      end

      it "should eval stddev" do
        _(Expression.new('stddev([1, 2, 3])').eval).must_equal 0.816496580927726
      end

      it "should eval mode" do
        _(Expression.new('mode([1, 2, 2, 3])').eval).must_equal 2
      end

      it "should eval all" do
        _(Expression.new('all([true, true, true])').eval).must_equal true
        _(Expression.new('all([true, false, true])').eval).must_equal false
      end

      it "should eval any" do
        _(Expression.new('any([true, false, false])').eval).must_equal true
        _(Expression.new('any([false, false, false])').eval).must_equal false
      end

      it "should eval sublist" do
        _(Expression.new('sublist([1, 2, 3], 1, 2)').eval).must_equal [1, 2]
      end

      it "should eval append" do
        _(Expression.new('append([1, 2, 3], 4)').eval).must_equal [1, 2, 3, 4]
      end

      it "should eval concatenate" do
        _(Expression.new('concatenate([1, 2, 3], [4, 5, 6])').eval).must_equal [1, 2, 3, 4, 5, 6]
      end

      it "should eval insert before" do
        _(Expression.new('insert before([1, 2, 3], 2, 4)').eval).must_equal [1, 4, 2, 3]
      end

      it "should eval remove" do
        _(Expression.new('remove([1, 2, 3], 2)').eval).must_equal [1, 3]
      end

      it "should eval reverse" do
        _(Expression.new('reverse([1, 2, 3])').eval).must_equal [3, 2, 1]
      end

      it "should eval index of" do
        _(Expression.new('index of([1, 2, 3], 2)').eval).must_equal 2
      end

      it "should eval union" do
        _(Expression.new('union([1, 2, 3], [4, 5, 6])').eval).must_equal [1, 2, 3, 4, 5, 6]
      end

      it "should eval distinct values" do
        _(Expression.new('distinct values([1, 2, 2, 3])').eval).must_equal [1, 2, 3]
      end

      it "should eval duplicate values" do
        _(Expression.new('duplicate values([1, 2, 2, 3])').eval).must_equal [2]
      end

      it "should eval flatten" do
        _(Expression.new('flatten([[1, 2], [3, 4]])').eval).must_equal [1, 2, 3, 4]
      end

      it "should eval sort" do
        _(Expression.new('sort([3, 2, 1])').eval).must_equal [1, 2, 3]
      end

      it "should eval string join" do
        _(Expression.new('string join(["Hello", "world"], " ")').eval).must_equal "Hello world"
      end
    end

    describe :context do
      it "should eval get value" do
        _(Expression.new('get value({"foo": "bar"}, "foo")').eval).must_equal "bar"
      end

      it "should eval context put" do
        _(Expression.new('context put({"foo": "baz"}, "foo", "bar")').eval).must_equal({ "foo" => "bar" })
        _(Expression.new('context put({}, "foo", "bar")').eval).must_equal({ "foo" => "bar" })
      end

      it "should eval context merge" do
        _(Expression.new('context merge({"foo": "bar"}, {"bar": "baz"})').eval).must_equal({ "foo" => "bar", "bar" => "baz" })
      end

      it "should eval get entries" do
        _(Expression.new('get entries({"foo": "bar"})').eval).must_equal({ "foo" => "bar" }.entries)
      end
    end

    describe :temporal do
      it "should eval now" do
        _(Expression.new('now()').eval).must_be_kind_of Time
      end

      it "should eval today" do
        _(Expression.new('today()').eval).must_be_kind_of Date
      end

      it "should eval day of week" do
        _(Expression.new('day of week(date("1963-1-1"))').eval).must_equal 2
      end

      it "should eval day of year" do
        _(Expression.new('day of year(date("1963-1-1"))').eval).must_equal 1
      end

      it "should eval week of year" do
        _(Expression.new('week of year(date("1963-1-1"))').eval).must_equal 1
      end

      it "should eval month of year" do
        _(Expression.new('month of year(date("1963-1-1"))').eval).must_equal 1
      end
    end

    describe :misc do
    end
  end
end
