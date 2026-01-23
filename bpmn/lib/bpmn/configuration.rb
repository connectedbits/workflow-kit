# frozen_string_literal: true

module BPMN
  class Configuration
    attr_accessor :services, :listener

    def initialize
      @services = HashWithIndifferentAccess.new
    end
  end
end
