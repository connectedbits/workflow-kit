# frozen_string_literal: true

module SpotFeel
  class UnaryTests < Expression

    def tree
      @tree ||= Parser.parse_test(text)
    end

    def test(input, variables = {})
      tree.eval(functions.merge(variables)).call(input)
    end
  end
end
