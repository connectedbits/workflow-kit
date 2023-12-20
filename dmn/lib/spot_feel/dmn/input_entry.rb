# frozen_string_literal: true

module SpotFeel
  module Dmn
    class InputEntry
      attr_accessor :id, :test

      def initialize(id: nil, test: nil)
        @id = id
        @test = test
      end

      def self.from_xml(xml)
        InputEntry.new(
          id: xml["id"],
          test: xml["text"],
        )
      end
    end
  end
end
