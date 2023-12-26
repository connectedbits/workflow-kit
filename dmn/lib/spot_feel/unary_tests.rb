module SpotFeel
  class UnaryTests < Expression

    def tree
      @tree ||= Parser.parse_test(text)
    end

    def test(input, context = {})
      tree.eval(ActiveSupport::HashWithIndifferentAccess.new(context.merge(functions))).call(input)  
    end
  end
end