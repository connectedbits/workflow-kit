# frozen_string_literal: true

require "spot_flow/version"

require "active_support"
require "active_support/time"
require "active_support/core_ext/hash"
require "active_support/core_ext/object/json"
require "active_support/configurable"
require "active_model"

require "spot_feel"

require "spot_flow/bpmn"
require "spot_flow/context"
require "spot_flow/execution"

module SpotFlow
  include ActiveSupport::Configurable

  #
  # Entry point for starting a process execution.
  #
  def self.new(sources = [])
    Context.new(sources)
  end

  #
  # Entry point for continuing a process execution.
  #
  def self.restore(sources = [], execution_state:)
    Context.new(sources).restore(execution_state)
  end

  #
  # Extract processes from a BMPN XML file.
  #
  def self.processes_from_xml(xml)
    Bpmn::Definitions.from_xml(xml)&.processes || []
  end

  #
  # Extract decisions from a DMN XML file.
  #
  def self.decisions_from_xml(xml)
    definitions = SpotFeel.definitions_from_xml(xml)
    definitions.decisions
  end
end
