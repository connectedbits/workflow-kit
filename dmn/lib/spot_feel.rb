# frozen_string_literal: true

require_relative "spot_feel/version"

require "awesome_print"

require "active_support"
require "active_support/duration"
require "active_support/time"
require "active_support/core_ext/hash"
require "active_support/core_ext/object/json"

require "treetop"

require "spot_feel/node"
require "spot_feel/builtin_functions"
require "spot_feel/dmn"

module SpotFeel

  Treetop.load(File.expand_path(File.join(File.dirname(__FILE__), 'spot_feel/spot_feel.treetop')))

  class SyntaxError < StandardError; end

  def self.parse(expression)
    SpotFeelParser.new.parse(expression).tap do |ast|
      raise SyntaxError, "Invalid expression" unless ast
    end
  end

  def self.parse_test(expression)
    SpotFeelParser.new.parse(expression, root: :simple_unary_tests).tap do |ast|
      raise SyntaxError, "Invalid expression" unless ast
    end
  end

  def self.eval(expression, context: {})
    parse(expression).eval(context.merge(SpotFeel.builtin_functions))
  end

  def self.test(input, expression, context: {})
    parse_test(expression).eval(context).call(input)
  end

  def self.decisions_from_xml(xml)
    SpotFeel::Dmn::Decision.decisions_from_xml(xml)
  end

  def self.decide(decision_id, decisions:, context: {})
    SpotFeel::Dmn::Decision.decide(decision_id, decisions:, context:)
  end
end
