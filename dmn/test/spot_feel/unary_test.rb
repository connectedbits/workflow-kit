# frozen_string_literal: true

require "test_helper"

module SpotFeel
  #
  # Unary-Tests
  #
  # https://docs.camunda.io/docs/1.3/reference/feel/language-guide/feel-unary-tests/#:~:text=Unary%2DTests%20can%20be%20used,be%20either%20true%20or%20false%20.
  #
  describe :unary_tests do
    it "should always pass with '-'" do
      _(SpotFeel.test(3, '-')).must_equal true
      _(SpotFeel.test(2, '-')).must_equal true
    end

    it "should default to equality" do
      _(SpotFeel.test(3, '3')).must_equal true
      _(SpotFeel.test(2, '3')).must_equal false
    end

    it "should support multiple tests" do
      #_(SpotFeel.test(3, '1,2,3')).must_equal true
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
  end
end
