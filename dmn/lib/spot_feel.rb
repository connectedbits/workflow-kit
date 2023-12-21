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
require "spot_feel/parser"
require "spot_feel/dmn"

module SpotFeel
  class SyntaxError < StandardError; end

  def self.parse(expression)
    Parser.parse(expression)
  end

  def self.parse_test(expression)
    Parser.parse_test(expression)
  end

  def self.eval(expression, context: {})
    Parser.eval(expression, context:)
  end

  def self.test(input, expression, context: {})
    Parser.test(input, expression, context:)
  end

  def self.decisions_from_xml(xml)
    Dmn::Decision.decisions_from_xml(xml)
  end

  def self.decide(decision_id, decisions:, context: {})
    Dmn::Decision.decide(decision_id, decisions:, context:)
  end

  def self.named_variables(expression)
    Parser.named_variables(expression)
  end
end
