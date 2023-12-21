# frozen_string_literal: true

require "test_helper"

module SpotFeel

  #
  # Data Types
  #
  describe :data_types do
    describe :null do
      it "should eval null literal" do
        _(SpotFeel.eval('null')).must_be_nil
      end
    end

    describe :number do
      it "should eval integer literal" do
        _(SpotFeel.eval('314')).must_equal 314
      end

      it "should eval float literal" do
        _(SpotFeel.eval('3.14')).must_equal 3.14
      end

      it "should eval negative numerics" do
        _(SpotFeel.eval('-3.14')).must_equal(-3.14)
      end
    end

    describe :string do
      it "should eval string literals with double quotes" do 
        _(SpotFeel.eval('"hello"')).must_equal "hello"
      end

      it "should eval string literals with single quotes" do
        _(SpotFeel.eval("'hello'")).must_equal "hello"
      end

      it "should handle unicode strings" do
        _(SpotFeel.eval('"横綱"')).must_equal("横綱")
      end

      it "should handle string concatenation" do
        _(SpotFeel.eval('"hello" + "world"')).must_equal("helloworld")
      end
    end

    describe :boolean do
      it "should eval true literal" do
        _(SpotFeel.eval('true')).must_equal true
      end

      it "should eval false literal" do
        _(SpotFeel.eval('false')).must_equal false
      end
    end

    describe :temporal do
      it "should eval dates" do
        _(SpotFeel.eval('date("1963-12-23")')).must_equal Date.new(1963, 12, 23)
      end

      it "should eval times" do
        value = SpotFeel.eval('time("04:25:12")')
        _(value.class).must_equal Time

        value = SpotFeel.eval('time("14:10:00+02:00")')
        _(value.class).must_equal Time

        value = SpotFeel.eval('time("09:30:00@Europe/Rome")')
        _(value.class).must_equal Time
      end

      it "should eval date and times" do
        value = SpotFeel.eval('date and time("2017-06-23T04:25:12")')
        _(value.class).must_equal DateTime
        _(value.year).must_equal 2017
        _(value.month).must_equal 6
        _(value.day).must_equal 23
        _(value.hour).must_equal 4
        _(value.min).must_equal 25
        _(value.sec).must_equal 12
      end

      it "should eval durations" do
        value = SpotFeel.eval('duration("PT6H")')
        _(value.class).must_equal ActiveSupport::Duration
        _(value.in_hours).must_equal 6
      end
    end

    describe :list do
      it "should eval list literals (arrays)" do
        _(SpotFeel.eval('[ 2, 3, 4, 5 ]')).must_equal [2, 3, 4, 5]
        _(SpotFeel.eval('["John", "Paul", "George", "Ringo"]')).must_equal ["John", "Paul", "George", "Ringo"]
      end
    end

    describe :context do
      it "should eval context literals (hashes)" do
        _(SpotFeel.eval('{ "a": 1, "b": 2 }')).must_equal({ "a" => 1, "b" => 2 })
      end
    end
  end

  #
  # Expressions
  #
  describe :expressions do

    it "should support bracketed expressions" do
      node = SpotFeel.parse('(3 + 4) + 2')
      _(node).wont_be_nil
    end

    describe :arithmetic do
      describe :addition do
        it "should eval addition" do
          _(SpotFeel.eval('1 + 1')).must_equal 2
        end
      end

      describe :subtraction do
        it "should eval addition" do
          _(SpotFeel.eval('1 - 1')).must_equal 0
        end
      end

      describe :multiplication do
        it "should eval mulitiplication" do
          _(SpotFeel.eval('2 * 3')).must_equal 6
        end
      end

      describe :division do
        it "should eval division" do
          _(SpotFeel.eval('6 / 2')).must_equal 3
        end
      end

      describe :exponentiation do
        it "should eval exponentiation" do
          _(SpotFeel.eval('2 ** 3')).must_equal 8
        end
      end

      it "should eval brakened arithmetic" do
        _(SpotFeel.eval('2 + (3 + 3)')).must_equal 8
      end
    end

    describe :comparison do
      it "should parse equal to" do
        _(SpotFeel.eval('1 = 1')).must_equal true
        _(SpotFeel.eval('1 = 2')).must_equal false
      end

      it "should parse not equal to" do
        _(SpotFeel.eval('1 != 2')).must_equal true
        _(SpotFeel.eval('1 != 1')).must_equal false
      end

      it "should parse less than" do
        _(SpotFeel.eval('1 < 2')).must_equal true
        _(SpotFeel.eval('1 < 1')).must_equal false
      end

      it "should parse less than or equal to" do
        _(SpotFeel.eval('1 <= 2')).must_equal true
        _(SpotFeel.eval('3 <= 2')).must_equal false
      end

      it "should parse greater than" do
        _(SpotFeel.eval('2 > 1')).must_equal true
        _(SpotFeel.eval('2 > 2')).must_equal false
      end

      it "should parse greater than or equal to" do
        _(SpotFeel.eval('2 >= 1')).must_equal true
        _(SpotFeel.eval('2 >= 3')).must_equal false
      end
    end

    describe :qualified_name do
      it "should evaluate an identifier from the context" do
        _(SpotFeel.eval('name', context: { name: "John" })).must_equal("John")
      end

      it "should evaluate nested identifiers" do
        _(SpotFeel.eval('person.name', context: { person: { name: "John" } })).must_equal("John")
      end
    end

    describe :function_invocation do
      it "should invoke a function" do
        _(SpotFeel.eval('reverse("Hello World")', context: { reverse: proc { |str| str.reverse } })).must_equal "dlroW olleH"
      end

      it "should parse single parameter" do
        _(SpotFeel.eval('reverse("Hello World")', context: { reverse: proc { |str| str.reverse } })).must_equal "dlroW olleH"
      end

      it "should reference variables in the context" do
        _(SpotFeel.eval('greet(name)', context: { name: 'Eric', greet: proc { |name| "Hi #{name}" } })).must_equal "Hi Eric"
      end

      it "should parse multiple parameters" do
        _(SpotFeel.eval('plus(1, 2)', context: { plus: proc { |x, y| x + y } })).must_equal 3
      end
    end

    describe :if_expression do
      it "should parse if expressions" do
        _(SpotFeel.eval('if true then "yes" else "no"')).must_equal "yes"
      end

      it "should return else when evaluating null" do
        # NOTE: If the condition c doesn't evaluate to a boolean value (e.g. null), it executes the expression b
        _(SpotFeel.eval('if null then "low" else "high"')).must_equal "high"
      end
    end
  end

  #
  # Unary Tests
  #
  describe :unary_tests do
    it "should always pass with '-'" do
      _(SpotFeel.test(3, '-')).must_equal true
      _(SpotFeel.test(2, '-')).must_equal true
    end

    describe :comparison do
      it "should default to equality" do
        _(SpotFeel.test(3, '3')).must_equal true
        _(SpotFeel.test(2, '3')).must_equal false
      end

      it "should test unary operators" do
        _(SpotFeel.test(3, '< 4')).must_equal true
        _(SpotFeel.test(2, '< 2')).must_equal false
        _(SpotFeel.test(3, '<= 3')).must_equal true
        _(SpotFeel.test(2, '<= 1')).must_equal false
      end
    end

    describe :interval do
      it "should support open intervals" do
        _(SpotFeel.test(3, '(2..4)')).must_equal true
        _(SpotFeel.test(5, '(2..4)')).must_equal false
        _(SpotFeel.test(2, '(2..4)')).must_equal false
        _(SpotFeel.test(4, '(2..4)')).must_equal false
      end

      it "should support closed intervals" do
        _(SpotFeel.test(3, '[2..4]')).must_equal true
        _(SpotFeel.test(2, '[2..4]')).must_equal true
        _(SpotFeel.test(1, '[2..4]')).must_equal false
      end
    end

    describe :disjunction do
      it "should test disjunction" do
        _(SpotFeel.test(3, '2,3,4')).must_equal true
        _(SpotFeel.test(3, '< 10, > 50')).must_equal true
      end
    end

    describe :negation do
      it "should test negation" do
        _(SpotFeel.test("valid", 'not("valid")')).must_equal false
        _(SpotFeel.test(1, 'not(2,3)')).must_equal true
      end
    end

    describe :expression do
      it "should test expressions" do
        # It's possible to use an expression instead of an operator. The input
        # can be accessed using the `?` symbol.
        #_(SpotFeel.test("my_file.xml", 'ends with(?, ".xml")')).must_equal true
        #_(SpotFeel.test(nil, 'ends with("Hello world", "world")')).must_equal true
      end
    end
  end
end
