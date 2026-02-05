# frozen_string_literal: true

module FEEL
  # Load the Treetop grammar which defines FEEL::Parser < Treetop::Runtime::CompiledParser

  # Special handling because this generated file causes lots of Ruby warnings
  # about formatting.
  verbose, $VERBOSE = $VERBOSE, nil
  Treetop.load(File.expand_path(File.join(File.dirname(__FILE__), "feel.treetop")))
  $VERBOSE = verbose

  # Reopen the Treetop-generated Parser class to add convenience methods
  class Parser
    @@parser = new

    def self.parse(expression, root: nil)
      @@parser.parse(expression, root: root).tap do |ast|
        raise SyntaxError, "Invalid expression: #{expression.inspect}" unless ast
      end
    end

    def self.parse_test(expression)
      @@parser.parse(expression || "-", root: :simple_unary_tests).tap do |ast|
        raise SyntaxError, "Invalid unary test: #{expression.inspect}" unless ast
      end
    end

    def self.clean_tree(root_node)
      return if(root_node.elements.nil?)
      root_node.elements.delete_if{ |node| node.class.name == "Treetop::Runtime::SyntaxNode" }
      root_node.elements.each { |node| self.clean_tree(node) }
    end
  end
end
