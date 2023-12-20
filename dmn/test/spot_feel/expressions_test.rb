# frozen_string_literal: true

require "test_helper"

module SpotFeel
  #
  # Expressions
  #
  # https://docs.camunda.io/docs/components/modeler/feel/language-guide/feel-expressions-introduction/
  #
  describe :expressions do

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
end
