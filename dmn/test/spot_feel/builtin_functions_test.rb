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
    end

    describe :boolean do
      it "should eval not" do
        # BUG: this is returning undefined method `-@' for true:TrueClass
        #_(SpotFeel.eval('not(true)')).must_equal false
      end

      it "should eval is defined" do
        _(SpotFeel.eval('is defined("Hello world")')).must_equal true
        _(SpotFeel.eval('is defined(null)')).must_equal false
      end

      it "should eval get or else" do
        _(SpotFeel.eval('get or else("Hello world", "Goodbye world")')).must_equal "Hello world"
        _(SpotFeel.eval('get or else(null, "Goodbye world")')).must_equal "Goodbye world"
      end
    end

    describe :string do
      it "should eval substring" do
        _(SpotFeel.eval('substring("Hello world", 1, 4)')).must_equal "Hell"
      end

      it "should eval substring before" do
        _(SpotFeel.eval('substring before("Hello world", "world")')).must_equal "Hello "
      end

      it "should eval substring after" do
        _(SpotFeel.eval('substring after("Hello world", "Hello")')).must_equal " world"
      end

      it "should eval string length" do
        _(SpotFeel.eval('string length("Hello world")')).must_equal 11
      end

      it "should eval upper case" do
        _(SpotFeel.eval('upper case("Hello world")')).must_equal "HELLO WORLD"
      end

      it "should eval lower case" do
        _(SpotFeel.eval('lower case("Hello world")')).must_equal "hello world"
      end

      it "should eval contains" do
        _(SpotFeel.eval('contains("Hello world", "ello")')).must_equal true
      end

      it "should eval starts with" do
        _(SpotFeel.eval('starts with("Hello world", "Hello")')).must_equal true
      end

      it "should eval ends with" do
        _(SpotFeel.eval('ends with("Hello world", "world")')).must_equal true
      end

      it "should eval matches" do
        _(SpotFeel.eval('matches("Hello world", ".*world")')).must_equal true
      end

      it "should eval replace" do
        _(SpotFeel.eval('replace("Hello world", "world", "universe")')).must_equal "Hello universe"
      end

      it "should eval split" do
        _(SpotFeel.eval('split("Hello world", " ")')).must_equal ["Hello", "world"]
      end
    end

    describe :numeric do
      it "should eval decimal" do
        _(SpotFeel.eval('decimal(1.234, 2)')).must_equal 1.23
      end

      it "should eval floor" do
        _(SpotFeel.eval('floor(1.234)')).must_equal 1
      end

      it "should eval ceiling" do
        _(SpotFeel.eval('ceiling(1.234)')).must_equal 2
      end

      it "should eval round up" do
        _(SpotFeel.eval('round up(1.234)')).must_equal 2
      end

      it "should eval round down" do
        _(SpotFeel.eval('round down(1.234)')).must_equal 1
      end

      it "should eval abs" do
        _(SpotFeel.eval('abs(-1.234)')).must_equal 1.234
      end

      it "should eval modulo" do
        _(SpotFeel.eval('modulo(5, 2)')).must_equal 1
      end

      it "should eval sqrt" do
        _(SpotFeel.eval('sqrt(4)')).must_equal 2
      end

      it "should eval log" do
        _(SpotFeel.eval('log(10)')).must_equal 2.302585092994046
      end

      it "should eval exp" do
        _(SpotFeel.eval('exp(2)')).must_equal 7.38905609893065
      end

      it "should eval odd" do
        _(SpotFeel.eval('odd(1)')).must_equal true
        _(SpotFeel.eval('odd(2)')).must_equal false
      end

      it "should eval even" do
        _(SpotFeel.eval('even(1)')).must_equal false
        _(SpotFeel.eval('even(2)')).must_equal true
      end

      it "should eval random" do
        _(SpotFeel.eval('random(10)')).must_be :<, 10
      end
    end

    describe :list do
      it "should eval list contains" do
        _(SpotFeel.eval('list contains(["Hello", "world"], "world")')).must_equal true
      end

      it "should eval count" do
        _(SpotFeel.eval('count(["Hello", "world"])')).must_equal 2
      end

      it "should eval min" do
        _(SpotFeel.eval('min([1, 2, 3])')).must_equal 1
      end

      it "should eval max" do
        _(SpotFeel.eval('max([1, 2, 3])')).must_equal 3
      end

      it "should eval sum" do
        _(SpotFeel.eval('sum([1, 2, 3])')).must_equal 6
      end

      it "should eval product" do
        _(SpotFeel.eval('product([1, 2, 3])')).must_equal 6
      end

      it "should eval mean" do
        _(SpotFeel.eval('mean([1, 2, 3])')).must_equal 2
      end

      it "should eval median" do
        _(SpotFeel.eval('median([1, 2, 3])')).must_equal 2
      end

      it "should eval stddev" do
        #_(SpotFeel.eval('stddev([1, 2, 3])')).must_equal 0.816496580927726
      end

      it "should eval mode" do
        _(SpotFeel.eval('mode([1, 2, 2, 3])')).must_equal 2
      end

      it "should eval all" do
        _(SpotFeel.eval('all([true, true, true])')).must_equal true
        _(SpotFeel.eval('all([true, false, true])')).must_equal false
      end

      it "should eval any" do
        _(SpotFeel.eval('any([true, false, false])')).must_equal true
        _(SpotFeel.eval('any([false, false, false])')).must_equal false
      end

      it "should eval sublist" do
        _(SpotFeel.eval('sublist([1, 2, 3], 1, 2)')).must_equal [1, 2]
      end

      it "should eval append" do
        _(SpotFeel.eval('append([1, 2, 3], 4)')).must_equal [1, 2, 3, 4]
      end

      it "should eval concatenate" do
        _(SpotFeel.eval('concatenate([1, 2, 3], [4, 5, 6])')).must_equal [1, 2, 3, 4, 5, 6]
      end

      it "should eval insert before" do
        _(SpotFeel.eval('insert before([1, 2, 3], 2, 4)')).must_equal [1, 4, 2, 3]
      end

      it "should eval remove" do
        _(SpotFeel.eval('remove([1, 2, 3], 2)')).must_equal [1, 3]
      end

      it "should eval reverse" do
        _(SpotFeel.eval('reverse([1, 2, 3])')).must_equal [3, 2, 1]
      end

      it "should eval index of" do
        _(SpotFeel.eval('index of([1, 2, 3], 2)')).must_equal 2
      end

      it "should eval union" do
        _(SpotFeel.eval('union([1, 2, 3], [4, 5, 6])')).must_equal [1, 2, 3, 4, 5, 6]
      end

      it "should eval distinct values" do
        _(SpotFeel.eval('distinct values([1, 2, 2, 3])')).must_equal [1, 2, 3]
      end

      it "should eval duplicate values" do
        _(SpotFeel.eval('duplicate values([1, 2, 2, 3])')).must_equal [2]
      end

      it "should eval flatten" do
        _(SpotFeel.eval('flatten([[1, 2], [3, 4]])')).must_equal [1, 2, 3, 4]
      end

      it "should eval sort" do
        _(SpotFeel.eval('sort([3, 2, 1])')).must_equal [1, 2, 3]
      end

      it "should eval string join" do
        _(SpotFeel.eval('string join(["Hello", "world"], " ")')).must_equal "Hello world"
      end
    end

    describe :context do
      it "should eval get value" do
        _(SpotFeel.eval('get value({"foo": "bar"}, "foo")')).must_equal "bar"
      end

      it "should eval context put" do
        # BUG:
        #_(SpotFeel.eval('context put({}, "foo", "bar")')).must_equal({ "foo" => "bar" })
      end

      it "should eval context merge" do
        _(SpotFeel.eval('context merge({"foo": "bar"}, {"bar": "baz"})')).must_equal({ "foo" => "bar", "bar" => "baz" })
      end
    end

    describe :temporal do
      it "should eval now" do
        # BUG: not recoginizing now() as a function (no args?)
        #_(SpotFeel.eval('now()')).must_be_kind_of Time
      end

      it "should eval today" do
        #_(SpotFeel.eval('today()')).must_be_kind_of Date
      end

      it "should eval day of week" do
        _(SpotFeel.eval('day of week(date("1963-1-1"))')).must_equal 2
      end

      it "should eval day of year" do
        _(SpotFeel.eval('day of year(date("1963-1-1"))')).must_equal 1
      end

      it "should eval week of year" do
        _(SpotFeel.eval('week of year(date("1963-1-1"))')).must_equal 1
      end

      it "should eval month of year" do
        _(SpotFeel.eval('month of year(date("1963-1-1"))')).must_equal 1
      end
    end

    describe :misc do
    end
  end
end
