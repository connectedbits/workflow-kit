# frozen_string_literal: true

require "test_helper"

module SpotFeel
  #
  # Builtin Functions
  #
  # https://docs.camunda.io/docs/components/modeler/feel/builtin-functions/feel-built-in-functions-introduction/
  #
  describe :builtin_functions do
    describe :boolean do
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
    end

    describe :list do
    end

    describe :context do
    end

    describe :temporal do
    end

    describe :conversion do
    end

    describe :misc do
    end
  end
end
