# frozen_string_literal: true

module DMN
  class Configuration
    attr_accessor :functions, :strict

    def initialize
      @functions = HashWithIndifferentAccess.new
      @strict = false
    end
  end
end
