# frozen_string_literal: true

guard(:minitest,
  all_on_start: false,
) do
  watch(%r{^test/test_helper\.rb$}) { "test" }
  watch(%r{^lib/(.+)\.rb$}) { |m| "test/#{m[1]}_test.rb" }
  watch(%r{^lib/spot_feel/spot_feel.treetop}) { "test/spot_feel/expression_test.rb" }
  watch(%r{^lib/spot_feel/node.rb}) { "test/spot_feel/expression_test.rb" }
  watch(%r{^test/.+_test\.rb$})
end
