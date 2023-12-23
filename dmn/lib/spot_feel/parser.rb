# frozen_string_literal: true

module SpotFeel
  class Parser
    # Load the Treetop grammar from the 'spot_feel' file, and create a new
    # instance of that parser as a class variable so we don't have to re-create
    # it every time we need to parse a string
    Treetop.load(File.expand_path(File.join(File.dirname(__FILE__), 'spot_feel.treetop')))
    @@parser = SpotFeelParser.new

    def self.parse(expression, root: nil)
      @@parser.parse(expression, root:).tap do |ast|
        raise SyntaxError, "Invalid expression" unless ast
      end
    end
  
    def self.parse_test(expression)
      @@parser.parse(expression || '-', root: :simple_unary_tests).tap do |ast|
        raise SyntaxError, "Invalid unary test" unless ast
      end
    end
  
    def self.eval(expression, context: {})
      ctx = ActiveSupport::HashWithIndifferentAccess.new(context.merge(SpotFeel.builtin_functions))
      parse(expression).eval(ctx)
    end
  
    def self.test(input, expression, context: {})
      # Replace ? with input, but not when ? is inside a string literal
      #expression = expression.gsub(/(?<=\()?\?(?=\,)/) { |match| "\"#{input}\"" }
      ctx = ActiveSupport::HashWithIndifferentAccess.new(context.merge(SpotFeel.builtin_functions))
      parse_test(expression).eval(ctx).call(input)
    end

    def valid_expression?(expression)
      @@parser.parse(expression).present?
    end

    def valid_unary_test?(expression)
      @@parser.parse_test(expression).present?
    end

    def self.named_variables(expression)
      # Parse the expression
      tree = parse(expression)
      return [] if tree.nil?

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
  
    def self.clean_tree(root_node)
      return if(root_node.elements.nil?)
      root_node.elements.delete_if{|node| node.class.name == "Treetop::Runtime::SyntaxNode" }
      root_node.elements.each {|node| self.clean_tree(node) }
    end
  end
end
