# frozen_string_literal: true

require "test_helper"

module SpotFeel
  describe :Expression do

    it "should support bracketed expressions" do
      tree = Expression.new('(3 + 4) + 2')
      _(tree.valid?).must_equal true
    end
  
    describe :data_types do
      describe :null do
        it "should eval null literal" do
          _(Expression.new('null').eval).must_be_nil
        end
      end
  
      describe :number do
        it "should eval integer literal" do
          _(Expression.new('314').eval).must_equal 314
        end
  
        it "should eval float literal" do
          _(Expression.new('3.14').eval).must_equal 3.14
        end
  
        it "should eval negative integers" do
          _(Expression.new('-314').eval).must_equal(-314)
        end
  
        it "should eval negative floats" do
          _(Expression.new('-3.14').eval).must_equal(-3.14)
        end
      end
  
      describe :string do
        it "should eval string literals with double quotes" do 
          _(Expression.new('"hello"').eval).must_equal "hello"
        end
  
        it "should eval string literals with single quotes" do
          _(Expression.new("'hello'").eval).must_equal "hello"
        end
  
        it "should handle unicode strings" do
          _(Expression.new('"横綱"').eval).must_equal("横綱")
        end
  
        it "should handle string concatenation" do
          _(Expression.new('"hello" + "world"').eval).must_equal("helloworld")
        end
      end
  
      describe :boolean do
        it "should eval true literal" do
          _(Expression.new('true').eval).must_equal true
        end
  
        it "should eval false literal" do
          _(Expression.new('false').eval).must_equal false
        end
      end
  
      describe :temporal do
        it "should eval dates" do
          _(Expression.new('date("1963-12-23")').eval).must_equal Date.new(1963, 12, 23)
        end
  
        it "should eval times" do
          value = Expression.new('time("04:25:12")').eval
          _(value.class).must_equal Time
  
          value = Expression.new('time("14:10:00+02:00")').eval
          _(value.class).must_equal Time
  
          value = Expression.new('time("09:30:00@Europe/Rome")').eval
          _(value.class).must_equal Time
        end
  
        it "should eval date and times" do
          value = Expression.new('date and time("2017-06-23T04:25:12")').eval
          _(value.class).must_equal DateTime
          _(value.year).must_equal 2017
          _(value.month).must_equal 6
          _(value.day).must_equal 23
          _(value.hour).must_equal 4
          _(value.min).must_equal 25
          _(value.sec).must_equal 12
        end
  
        it "should eval durations" do
          value = Expression.new('duration("PT6H")').eval
          _(value.class).must_equal ActiveSupport::Duration
          _(value.in_hours).must_equal 6
        end
  
        it "should support date math" do
          _(Expression.new('date("2019-01-01") + duration("P1D")').eval).must_equal Date.parse("2019-01-02")
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
          _(Expression.new('[ 2, 3, 4, 5 ]').eval).must_equal [2, 3, 4, 5]
          _(Expression.new('["John", "Paul", "George", "Ringo"]').eval).must_equal ["John", "Paul", "George", "Ringo"]
        end
      end
  
      describe :context do
        it "should eval context literals (hashes)" do
          _(Expression.new('{ "a": 1, "b": 2 }').eval).must_equal({ "a" => 1, "b" => 2 })
        end
      end
    end  

    describe :arithmetic do
      describe :addition do
        it "should eval addition" do
          _(Expression.new('1 + 1').eval).must_equal 2
        end
      end

      describe :subtraction do
        it "should eval addition" do
          _(Expression.new('1 - 1').eval).must_equal 0
        end
      end

      describe :multiplication do
        it "should eval mulitiplication" do
          _(Expression.new('2 * 3').eval).must_equal 6
        end
      end

      describe :division do
        it "should eval division" do
          _(Expression.new('6 / 2').eval).must_equal 3
        end
      end

      describe :exponentiation do
        it "should eval exponentiation" do
          _(Expression.new('2 ** 3').eval).must_equal 8
        end
      end

      it "should eval brakened arithmetic" do
        _(Expression.new('2 + (3 + 3)').eval).must_equal 8
      end
    end

    describe :comparison do
      it "should parse equal to" do
        _(Expression.new('1 = 1').eval).must_equal true
        _(Expression.new('1 = 2').eval).must_equal false
      end

      it "should parse not equal to" do
        _(Expression.new('1 != 2').eval).must_equal true
        _(Expression.new('1 != 1').eval).must_equal false
      end

      it "should parse less than" do
        _(Expression.new('1 < 2').eval).must_equal true
        _(Expression.new('1 < 1').eval).must_equal false
      end

      it "should parse less than or equal to" do
        _(Expression.new('1 <= 2').eval).must_equal true
        _(Expression.new('3 <= 2').eval).must_equal false
      end

      it "should parse greater than" do
        _(Expression.new('2 > 1').eval).must_equal true
        _(Expression.new('2 > 2').eval).must_equal false
      end

      it "should parse greater than or equal to" do
        _(Expression.new('2 >= 1').eval).must_equal true
        _(Expression.new('2 >= 3').eval).must_equal false
      end
    end

    describe :qualified_name do
      it "should evaluate an identifier from the context" do
        _(Expression.new('name').eval(name: "John")).must_equal("John")
      end

      it "should evaluate nested identifiers" do
        _(Expression.new('person.name').eval(person: { name: "John" })).must_equal("John")
      end
    end

    describe :function_invocation do
      it "should invoke a function" do
        _(Expression.new('reverse("Hello World")').eval(reverse: proc { |str| str.reverse })).must_equal "dlroW olleH"
      end

      it "should parse single parameter" do
        _(Expression.new('reverse("Hello World")').eval(reverse: proc { |str| str.reverse })).must_equal "dlroW olleH"
      end

      it "should reference variables in the context" do
        _(Expression.new('greet(name)').eval(name: 'Eric', greet: proc { |name| "Hi #{name}" })).must_equal "Hi Eric"
      end

      it "should parse multiple parameters" do
        _(Expression.new('plus(1, 2)').eval(plus: proc { |x, y| x + y })).must_equal 3
      end
    end

    describe :if_expression do
      it "should parse if expressions" do
        _(Expression.new('if (20 - (10 * 2)) > 0 then "Yes" else "No"').eval).must_equal "No"
      end

      it "should return else when evaluating null" do
        # NOTE: If the condition c doesn't evaluate to a boolean value (e.g. null), it executes the expression b
        _(Expression.new('if null then "low" else "high"').eval).must_equal "high"
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
        _(Expression.new('"Hello " + "World"').eval).must_equal "Hello World"
        _(Expression.new('"Very" + "Long" + "Word"').eval).must_equal "VeryLongWord"
      end
    end

    describe :qualified_names do
      it "should return an array variables used in an expression" do
        _(Expression.new("a + b").named_variables).must_equal %w[a b]
        _(Expression.new("person.income * person.age").named_variables).must_equal %w[person.income person.age]
      end
    end
  end
end