# frozen_string_literal: true

GEM_ROOT = File.join(File.dirname(__FILE__), "..")

require "minitest/autorun"
require "minitest/reporters"
require "minitest/spec"
require "minitest/focus"
require "active_support"
require "active_support/testing/time_helpers"
require "pry"

Time.zone_default = Time.find_zone!("UTC")

Minitest::Reporters.use!(
  Minitest::Reporters::ProgressReporter.new(color: true),
    ENV,
    Minitest.backtrace_filter,
)

require_relative "../lib/feel"

class Minitest::Spec
  include ActiveSupport::Testing::TimeHelpers

  before :each do
  end

  after :each do
  end

  def file_fixture(filename)
    Pathname.new(File.join(GEM_ROOT, "/test/fixtures/files", filename))
  end

  def fixture_source(filename)
    file_fixture(filename).read
  end

  def eval(expression, context: {})
    FEEL::Parser.new.evaluate(expression, context: context)
  end

  def unary(context, expression)
    FEEL::Parser.new.unary_test(expression, context: context)
  end
end
