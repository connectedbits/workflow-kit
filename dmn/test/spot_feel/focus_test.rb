# frozen_string_literal: true

require "test_helper"

module SpotFeel
  describe :focus do
    it "will parse a DMN file" do
      XmlHasher.configure do |config|
        config.snakecase = true
        config.ignore_namespaces = true
        config.string_keys = false
      end

      json = XmlHasher.parse(fixture_source("test_literal_decision.dmn"))
      _(json).wont_be_nil

      definitions = Dmn::Definitions.from_json(json[:definitions])
      _(definitions).wont_be_nil

      decision = definitions.decisions.first
      _(decision).wont_be_nil

      result = decision.evaluate({ "age" => 18 })
      _(result).must_equal({ "age_classification"=>"adult" })

      #pp definitions


      # moddle = XmlHasher.parse(fixture_source("dinner.dmn"))
      # puts moddle.pretty_inspect

      # moddle = XmlHasher.parse(fixture_source("test_literal_decision.dmn"))
      # puts moddle.pretty_inspect

      # moddle = XmlHasher.parse(fixture_source("test.dmn"))
      # puts moddle.pretty_inspect


    end
  end
end
