module SpotFeel
  class UnaryTests < Expression

    def tree
      @tree ||= Parser.parse_test(text)
    end

    def test(input, context = {})
      tree.eval(ActiveSupport::HashWithIndifferentAccess.new(functions.merge(context))).call(input)  
    end
  end
end