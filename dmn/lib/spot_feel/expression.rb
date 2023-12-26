module SpotFeel
  class Expression
    attr_reader :text

    def initialize(text)
      @text = text
    end

    def tree
      @tree ||= Parser.parse(text)
    end

    def eval(context = {})
      tree.eval(ActiveSupport::HashWithIndifferentAccess.new(context.merge(functions)))
    end

    def valid?
      tree.present?
    end

    def functions
      SpotFeel.builtin_function_named(named_functions)
    end

    def named_functions
      # Initialize a set to hold the qualified names
      function_names = Set.new

      # Define a lambda for the recursive function
      walk_tree = lambda do |node|
        # If the node is a qualified name, add it to the set
        if node.is_a?(SpotFeel::FunctionInvocation)
          function_names << node.fn_name.text_value
        end

        # Recursively walk the child nodes
        node.elements&.each do |child|
          walk_tree.call(child)
        end
      end

      # Start walking the tree from the root
      walk_tree.call(tree)

      # Return the array of functions
      function_names.to_a
    end

    def named_variables
      # Initialize a set to hold the qualified names
      qualified_names = Set.new

      # Define a lambda for the recursive function
      walk_tree = lambda do |node|
        # If the node is a qualified name, add it to the set
        if node.is_a?(SpotFeel::QualifiedName)
          qualified_names << node.text_value
        end

        # Recursively walk the child nodes
        node.elements&.each do |child|
          walk_tree.call(child)
        end
      end

      # Start walking the tree from the root
      walk_tree.call(tree)

      # Return the array of qualified names
      qualified_names.to_a
    end
  end
end