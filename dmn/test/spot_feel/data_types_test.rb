# frozen_string_literal: true

require "test_helper"

module SpotFeel
  #
  # https://docs.camunda.io/docs/components/modeler/feel/language-guide/feel-data-types/
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
end
