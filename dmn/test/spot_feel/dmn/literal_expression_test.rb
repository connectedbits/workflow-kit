# frozen_string_literal: true

require "test_helper"

module SpotFeel
  module Dmn
    describe LiteralExpression do
      it "should support bracketed expressions" do
        tree = LiteralExpression.new(text: '(3 + 4) + 2')
        _(tree.valid?).must_equal true
      end

      describe :data_types do
        describe :null do
          it "should eval null literal" do
            _(LiteralExpression.new(text: 'null').evaluate).must_be_nil
          end
        end

        describe :number do
          it "should eval integer literal" do
            _(LiteralExpression.new(text: '314').evaluate).must_equal 314
          end

          it "should eval float literal" do
            _(LiteralExpression.new(text: '3.14').evaluate).must_equal 3.14
          end

          it "should eval negative integers" do
            _(LiteralExpression.new(text: '-314').evaluate).must_equal(-314)
          end

          it "should eval negative floats" do
            _(LiteralExpression.new(text: '-3.14').evaluate).must_equal(-3.14)
          end
        end

        describe :string do
          it "should eval string literals with double quotes" do 
            _(LiteralExpression.new(text: '"hello"').evaluate).must_equal "hello"
          end

          it "should eval string literals with single quotes" do
            _(LiteralExpression.new(text: "'hello'").evaluate).must_equal "hello"
          end

          it "should handle unicode strings" do
            _(LiteralExpression.new(text: '"横綱"').evaluate).must_equal("横綱")
          end

          it "should handle string concatenation" do
            _(LiteralExpression.new(text: '"hello" + "world"').evaluate).must_equal("helloworld")
          end
        end

        describe :boolean do
          it "should eval true literal" do
            _(LiteralExpression.new(text: 'true').evaluate).must_equal true
          end

          it "should eval false literal" do
            _(LiteralExpression.new(text: 'false').evaluate).must_equal false
          end
        end

        describe :temporal do
          it "should eval dates" do
            _(LiteralExpression.new(text: 'date("1963-12-23")').evaluate).must_equal Date.new(1963, 12, 23)
          end

          it "should eval times" do
            value = LiteralExpression.new(text: 'time("04:25:12")').evaluate
            _(value.class).must_equal Time

            value = LiteralExpression.new(text: 'time("14:10:00+02:00")').evaluate
            _(value.class).must_equal Time

            value = LiteralExpression.new(text: 'time("09:30:00@Europe/Rome")').evaluate
            _(value.class).must_equal Time
          end

          it "should eval date and times" do
            value = LiteralExpression.new(text: 'date and time("2017-06-23T04:25:12")').evaluate
            _(value.class).must_equal DateTime
            _(value.year).must_equal 2017
            _(value.month).must_equal 6
            _(value.day).must_equal 23
            _(value.hour).must_equal 4
            _(value.min).must_equal 25
            _(value.sec).must_equal 12
          end

          it "should eval durations" do
            value = LiteralExpression.new(text: 'duration("PT6H")').evaluate
            _(value.class).must_equal ActiveSupport::Duration
            _(value.in_hours).must_equal 6
          end

          it "should support date math" do
            _(LiteralExpression.new(text: 'date("2019-01-01") + duration("P1D")').evaluate).must_equal Date.parse("2019-01-02")
          end

          it "should eval date properties" do
            # _(SpotFeel.eval('date("1963-12-23").year')).must_equal 1963
            # _(SpotFeel.eval('date("1963-12-23").month')).must_equal 12
            # _(SpotFeel.eval('date("1963-12-23").day')).must_equal 23
            # _(SpotFeel.eval('date("1963-12-23").weekday')).must_equal 1
          end
        end

        describe :list do
          it "should eval list literals (arrays)" do
            _(LiteralExpression.new(text: '[ 2, 3, 4, 5 ]').evaluate).must_equal [2, 3, 4, 5]
            _(LiteralExpression.new(text: '["John", "Paul", "George", "Ringo"]').evaluate).must_equal ["John", "Paul", "George", "Ringo"]
          end
        end

        describe :context do
          it "should eval context literals (hashes)" do
            _(LiteralExpression.new(text: '{ "a": 1, "b": 2 }').evaluate).must_equal({ "a" => 1, "b" => 2 })
          end
        end
      end

      describe :arithmetic do
        describe :addition do
          it "should eval addition" do
            _(LiteralExpression.new(text: '1 + 1').evaluate).must_equal 2
          end
        end

        describe :subtraction do
          it "should eval addition" do
            _(LiteralExpression.new(text: '1 - 1').evaluate).must_equal 0
          end
        end

        describe :multiplication do
          it "should eval mulitiplication" do
            _(LiteralExpression.new(text: '2 * 3').evaluate).must_equal 6
          end
        end

        describe :division do
          it "should eval division" do
            _(LiteralExpression.new(text: '6 / 2').evaluate).must_equal 3
          end
        end

        describe :exponentiation do
          it "should eval exponentiation" do
            _(LiteralExpression.new(text: '2 ** 3').evaluate).must_equal 8
          end
        end

        it "should eval brakened arithmetic" do
          _(LiteralExpression.new(text: '2 + (3 + 3)').evaluate).must_equal 8
        end
      end

      describe :comparison do
        it "should parse equal to" do
          _(LiteralExpression.new(text: '1 = 1').evaluate).must_equal true
          _(LiteralExpression.new(text: '1 = 2').evaluate).must_equal false
        end

        it "should parse not equal to" do
          _(LiteralExpression.new(text: '1 != 2').evaluate).must_equal true
          _(LiteralExpression.new(text: '1 != 1').evaluate).must_equal false
        end

        it "should parse less than" do
          _(LiteralExpression.new(text: '1 < 2').evaluate).must_equal true
          _(LiteralExpression.new(text: '1 < 1').evaluate).must_equal false
        end

        it "should parse less than or equal to" do
          _(LiteralExpression.new(text: '1 <= 2').evaluate).must_equal true
          _(LiteralExpression.new(text: '3 <= 2').evaluate).must_equal false
        end

        it "should parse greater than" do
          _(LiteralExpression.new(text: '2 > 1').evaluate).must_equal true
          _(LiteralExpression.new(text: '2 > 2').evaluate).must_equal false
        end

        it "should parse greater than or equal to" do
          _(LiteralExpression.new(text: '2 >= 1').evaluate).must_equal true
          _(LiteralExpression.new(text: '2 >= 3').evaluate).must_equal false
        end
      end

      describe :qualified_name do
        it "should evaluate an identifier from the context" do
          _(LiteralExpression.new(text: 'name').evaluate(name: "John")).must_equal("John")
        end

        it "should evaluate nested identifiers" do
          _(LiteralExpression.new(text: 'person.name').evaluate(person: { name: "John" })).must_equal("John")
        end
      end

      describe :function_invocation do
        it "should invoke a function" do
          SpotFeel.config.functions = { "reverse" => proc { |str| str.reverse } }
          _(LiteralExpression.new(text: 'reverse("Hello World")').evaluate).must_equal "dlroW olleH"
        end

        it "should parse single parameter" do
          SpotFeel.config.functions = { "reverse" => proc { |str| str.reverse } }
          _(LiteralExpression.new(text: 'reverse("Hello World")').evaluate).must_equal "dlroW olleH"
        end

        it "should reference variables in the context" do
          SpotFeel.config.functions = { "greet" => proc { |name| "Hi #{name}" } }
          _(LiteralExpression.new(text: 'greet(name)').evaluate(name: "Eric")).must_equal "Hi Eric"
        end

        it "should parse multiple parameters" do
          # Note: also works passing functions as variables
          _(LiteralExpression.new(text: 'plus(1, 2)').evaluate(plus: proc { |x, y| x + y })).must_equal 3
        end
      end

      describe :if_expression do
        it "should parse if expressions" do
          _(LiteralExpression.new(text: 'if (20 - (10 * 2)) > 0 then "Yes" else "No"').evaluate).must_equal "No"
        end

        it "should return else when evaluating null" do
          # NOTE: If the condition c doesn't evaluate to a boolean value (e.g. null), it executes the expression b
          _(LiteralExpression.new(text: 'if null then "low" else "high"').evaluate).must_equal "high"
        end

        it "should parse if expressions" do
          _(LiteralExpression.new(text: 'if true then "Eric" else "Dave"').evaluate(cool: true)).must_equal("Eric")
        end

        it "should parse if expressions" do
          _(LiteralExpression.new(text: 'if true then "Eric" else "Eli"').evaluate).must_equal("Eric")
          skip "BUG: This expression fails with syntax error"
          _(LiteralExpression.new(text: 'if condition then "Eric" else "Eli"').evaluate(condition: true)).must_equal("Eric")
        end
      end

      describe :for_expression do
        # for i in [1, 2, 3] return i * i   //➔ [1, 4, 9]
        # for i in 1..3 return i * i   //➔ [1, 4, 9]
        # for i in [1,2,3], j in [1,2,3] return i*j   //➔ [1, 2, 3, 2, 4, 6, 3, 6, 9]
      end

      describe :quantified_expression do
        # some i in [1, 2, 3] satisfies i > 2   //➔ true
        # some i in [1, 2, 3] satisfies i > 4   //➔ false
        # every i in [1, 2, 3] satisfies i > 1   //➔ false
        # every i in [1, 2, 3] satisfies i > 0   //➔ true
      end

      describe :in_expression do
        # 1 in [1..10]   //➔ true
        # 1 in (1..10]   //➔ false
        # 10 in [1..10]   //➔ true
        # 10 in [1..10)   //➔ false
      end

      describe :conjunction_disjunction do
        # true and true   //➔ true
        # true and false and null   //➔ false
        # true and null and true   //➔ null
        # true or false or null   //➔ true
        # false or false   //➔ false
        # false or null or false  //➔ null
        # true or false and false   //➔ true
        # (true or false) and false   //➔ false
      end

      describe :string_concatenation do
        it "should eval string concatenation" do
          _(LiteralExpression.new(text: '"Hello " + "World"').evaluate).must_equal "Hello World"
          _(LiteralExpression.new(text: '"Very" + "Long" + "Word"').evaluate).must_equal "VeryLongWord"
        end
      end

      describe :qualified_names do
        it "should return an array variables used in an expression" do
          _(LiteralExpression.new(text: "a + b").named_variables).must_equal %w[a b]
          _(LiteralExpression.new(text: "person.income * person.age").named_variables).must_equal %w[person.income person.age]
        end
      end

      describe :builtin_functions do
        describe :conversion do
          it "should eval string" do
            _(LiteralExpression.new(text: 'string(123)').evaluate).must_equal "123"
          end

          it "should eval number" do
            _(LiteralExpression.new(text: 'number("123")').evaluate).must_equal 123
          end
        end

        describe :boolean do
          it "should eval is defined" do
            _(LiteralExpression.new(text: 'is defined("Hello world")').evaluate).must_equal true
            _(LiteralExpression.new(text: 'is defined(null)').evaluate).must_equal false
          end

          it "should eval get or else" do
            _(LiteralExpression.new(text: 'get or else("Hello world", "Goodbye world")').evaluate).must_equal "Hello world"
            _(LiteralExpression.new(text: 'get or else(null, "Goodbye world")').evaluate).must_equal "Goodbye world"
          end
        end

        describe :string do
          it "should eval substring" do
            _(LiteralExpression.new(text: 'substring("Hello world", 1, 4)').evaluate).must_equal "Hell"
          end

          it "should eval substring before" do
            _(LiteralExpression.new(text: 'substring before("Hello world", "world")').evaluate).must_equal "Hello "
          end

          it "should eval substring after" do
            _(LiteralExpression.new(text: 'substring after("Hello world", "Hello")').evaluate).must_equal " world"
          end

          it "should eval string length" do
            _(LiteralExpression.new(text: 'string length("Hello world")').evaluate).must_equal 11
          end

          it "should eval upper case" do
            _(LiteralExpression.new(text: 'upper case("Hello world")').evaluate).must_equal "HELLO WORLD"
          end

          it "should eval lower case" do
            _(LiteralExpression.new(text: 'lower case("Hello world")').evaluate).must_equal "hello world"
          end

          it "should eval contains" do
            _(LiteralExpression.new(text: 'contains("Hello world", "ello")').evaluate).must_equal true
          end

          it "should eval starts with" do
            _(LiteralExpression.new(text: 'starts with("Hello world", "Hello")').evaluate).must_equal true
          end

          it "should eval ends with" do
            _(LiteralExpression.new(text: 'ends with("Hello world", "world")').evaluate).must_equal true
          end

          it "should eval matches" do
            _(LiteralExpression.new(text: 'matches("Hello world", ".*world")').evaluate).must_equal true
          end

          it "should eval replace" do
            _(LiteralExpression.new(text: 'replace("Hello world", "world", "universe")').evaluate).must_equal "Hello universe"
          end

          it "should eval split" do
            _(LiteralExpression.new(text: 'split("Hello world", " ")').evaluate).must_equal ["Hello", "world"]
          end

          it "should eval strip" do
            _(LiteralExpression.new(text: 'strip(" Hello world ")').evaluate).must_equal "Hello world"
          end

          it "should eval extract" do
            _(LiteralExpression.new(text: 'extract("Hello world", "(Hello) (world)")').evaluate).must_equal ["Hello", "world"]
          end
        end

        describe :numeric do
          it "should eval decimal" do
            _(LiteralExpression.new(text: 'decimal(1.234, 2)').evaluate).must_equal 1.23
          end

          it "should eval floor" do
            _(LiteralExpression.new(text: 'floor(1.234)').evaluate).must_equal 1
          end

          it "should eval ceiling" do
            _(LiteralExpression.new(text: 'ceiling(1.234)').evaluate).must_equal 2
          end

          it "should eval round up" do
            _(LiteralExpression.new(text: 'round up(1.234)').evaluate).must_equal 2
          end

          it "should eval round down" do
            _(LiteralExpression.new(text: 'round down(1.234)').evaluate).must_equal 1
          end

          it "should eval abs" do
            _(LiteralExpression.new(text: 'abs(-1.234)').evaluate).must_equal 1.234
          end

          it "should eval modulo" do
            _(LiteralExpression.new(text: 'modulo(5, 2)').evaluate).must_equal 1
          end

          it "should eval sqrt" do
            _(LiteralExpression.new(text: 'sqrt(4)').evaluate).must_equal 2
          end

          it "should eval log" do
            _(LiteralExpression.new(text: 'log(10)').evaluate).must_equal 2.302585092994046
          end

          it "should eval exp" do
            _(LiteralExpression.new(text: 'exp(2)').evaluate).must_equal 7.38905609893065
          end

          it "should eval odd" do
            _(LiteralExpression.new(text: 'odd(1)').evaluate).must_equal true
            _(LiteralExpression.new(text: 'odd(2)').evaluate).must_equal false
          end

          it "should eval even" do
            _(LiteralExpression.new(text: 'even(1)').evaluate).must_equal false
            _(LiteralExpression.new(text: 'even(2)').evaluate).must_equal true
          end

          it "should eval random number" do
            _(LiteralExpression.new(text: 'random number(10)').evaluate).must_be :<, 10
          end
        end

        describe :list do
          it "should eval list contains" do
            _(LiteralExpression.new(text: 'list contains(["Hello", "world"], "world")').evaluate).must_equal true
          end

          it "should eval count" do
            _(LiteralExpression.new(text: 'count(["Hello", "world"])').evaluate).must_equal 2
          end

          it "should eval min" do
            _(LiteralExpression.new(text: 'min([1, 2, 3])').evaluate).must_equal 1
          end

          it "should eval max" do
            _(LiteralExpression.new(text: 'max([1, 2, 3])').evaluate).must_equal 3
          end

          it "should eval sum" do
            _(LiteralExpression.new(text: 'sum([1, 2, 3])').evaluate).must_equal 6
          end

          it "should eval product" do
            _(LiteralExpression.new(text: 'product([1, 2, 3])').evaluate).must_equal 6
          end

          it "should eval mean" do
            _(LiteralExpression.new(text: 'mean([1, 2, 3])').evaluate).must_equal 2
          end

          it "should eval median" do
            _(LiteralExpression.new(text: 'median([1, 2, 3])').evaluate).must_equal 2
          end

          it "should eval stddev" do
            _(LiteralExpression.new(text: 'stddev([1, 2, 3])').evaluate).must_equal 0.816496580927726
          end

          it "should eval mode" do
            _(LiteralExpression.new(text: 'mode([1, 2, 2, 3])').evaluate).must_equal 2
          end

          it "should eval all" do
            _(LiteralExpression.new(text: 'all([true, true, true])').evaluate).must_equal true
            _(LiteralExpression.new(text: 'all([true, false, true])').evaluate).must_equal false
          end

          it "should eval any" do
            _(LiteralExpression.new(text: 'any([true, false, false])').evaluate).must_equal true
            _(LiteralExpression.new(text: 'any([false, false, false])').evaluate).must_equal false
          end

          it "should eval sublist" do
            _(LiteralExpression.new(text: 'sublist([1, 2, 3], 1, 2)').evaluate).must_equal [1, 2]
          end

          it "should eval append" do
            _(LiteralExpression.new(text: 'append([1, 2, 3], 4)').evaluate).must_equal [1, 2, 3, 4]
          end

          it "should eval concatenate" do
            _(LiteralExpression.new(text: 'concatenate([1, 2, 3], [4, 5, 6])').evaluate).must_equal [1, 2, 3, 4, 5, 6]
          end

          it "should eval insert before" do
            _(LiteralExpression.new(text: 'insert before([1, 2, 3], 2, 4)').evaluate).must_equal [1, 4, 2, 3]
          end

          it "should eval remove" do
            _(LiteralExpression.new(text: 'remove([1, 2, 3], 2)').evaluate).must_equal [1, 3]
          end

          it "should eval reverse" do
            _(LiteralExpression.new(text: 'reverse([1, 2, 3])').evaluate).must_equal [3, 2, 1]
          end

          it "should eval index of" do
            _(LiteralExpression.new(text: 'index of([1, 2, 3], 2)').evaluate).must_equal 2
          end

          it "should eval union" do
            _(LiteralExpression.new(text: 'union([1, 2, 3], [4, 5, 6])').evaluate).must_equal [1, 2, 3, 4, 5, 6]
          end

          it "should eval distinct values" do
            _(LiteralExpression.new(text: 'distinct values([1, 2, 2, 3])').evaluate).must_equal [1, 2, 3]
          end

          it "should eval duplicate values" do
            _(LiteralExpression.new(text: 'duplicate values([1, 2, 2, 3])').evaluate).must_equal [2]
          end

          it "should eval flatten" do
            _(LiteralExpression.new(text: 'flatten([[1, 2], [3, 4]])').evaluate).must_equal [1, 2, 3, 4]
          end

          it "should eval sort" do
            _(LiteralExpression.new(text: 'sort([3, 2, 1])').evaluate).must_equal [1, 2, 3]
          end

          it "should eval string join" do
            _(LiteralExpression.new(text: 'string join(["Hello", "world"], " ")').evaluate).must_equal "Hello world"
          end
        end

        describe :context do
          it "should eval get value" do
            _(LiteralExpression.new(text: 'get value({"foo": "bar"}, "foo")').evaluate).must_equal "bar"
          end

          it "should eval context put" do
            _(LiteralExpression.new(text: 'context put({"foo": "baz"}, "foo", "bar")').evaluate).must_equal({ "foo" => "bar" })
            _(LiteralExpression.new(text: 'context put({}, "foo", "bar")').evaluate).must_equal({ "foo" => "bar" })
          end

          it "should eval context merge" do
            _(LiteralExpression.new(text: 'context merge({"foo": "bar"}, {"bar": "baz"})').evaluate).must_equal({ "foo" => "bar", "bar" => "baz" })
          end

          it "should eval get entries" do
            _(LiteralExpression.new(text: 'get entries({"foo": "bar"})').evaluate).must_equal({ "foo" => "bar" }.entries)
          end
        end

        describe :temporal do
          it "should eval now" do
            _(LiteralExpression.new(text: 'now()').evaluate).must_be_kind_of Time
          end

          it "should eval today" do
            _(LiteralExpression.new(text: 'today()').evaluate).must_be_kind_of Date
          end

          it "should eval day of week" do
            _(LiteralExpression.new(text: 'day of week(date("1963-1-1"))').evaluate).must_equal 2
          end

          it "should eval day of year" do
            _(LiteralExpression.new(text: 'day of year(date("1963-1-1"))').evaluate).must_equal 1
          end

          it "should eval week of year" do
            _(LiteralExpression.new(text: 'week of year(date("1963-1-1"))').evaluate).must_equal 1
          end

          it "should eval month of year" do
            _(LiteralExpression.new(text: 'month of year(date("1963-1-1"))').evaluate).must_equal 1
          end
        end

        describe :misc do
        end
      end
    end
  end
end
