# frozen_string_literal: true

require "test_helper"

module FEEL
  describe Parser do
    it "should be a Treetop compiled parser" do
      _(Parser.ancestors).must_include Treetop::Runtime::CompiledParser
    end

    it "should parse and evaluate expressions" do
      _(Parser.parse("1 + 1").eval).must_equal 2
    end

    it "should parse unary tests" do
      _(Parser.parse_test("< 10")).wont_be_nil
    end
  end
end
