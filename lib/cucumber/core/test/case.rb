require 'cucumber/initializer'
require 'cucumber/core/test/result'

module Cucumber
  module Core
    module Test
      class Case
        include Cucumber.initializer(:test_steps, :source)

        def language
          feature.language
        end

        def describe_to(visitor, *args)
          visitor.test_case(self, *args) do |child_visitor=visitor|
            test_steps.each do |test_step|
              test_step.describe_to(child_visitor, *args)
            end
          end
          self
        end

        def describe_source_to(visitor, *args)
          source.each do |node|
            node.describe_to(visitor, *args)
          end
          self
        end

        def with_steps(test_steps)
          self.class.new(test_steps, source)
        end

        def prepend_steps(new_test_steps)
          with_steps(new_test_steps + test_steps)
        end

        def append_steps(new_test_steps)
          with_steps(test_steps + new_test_steps)
        end

        private

        def feature
          source.first
        end

      end
    end
  end
end
