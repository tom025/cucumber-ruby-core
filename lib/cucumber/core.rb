require 'cucumber/core/gherkin/parser'
require 'cucumber/core/compiler'
require 'cucumber/core/test/runner'
require 'cucumber/core/test/mapper'

module Cucumber
  module Core

    def parse(gherkin_documents, compiler)
      parser = Core::Gherkin::Parser.new(compiler)
      gherkin_documents.map do |document|
        parser.document(document, 'UNKNOWN')
      end
      self
    end

    def compile(gherkin_documents, receiver)
      compiler = Compiler.new(receiver)
      parse(gherkin_documents, compiler)
      self
    end

    def execute(gherkin_documents, mappings, report)
      runner = Test::Runner.new(report)
      hook_wrapper = Test::HookWrapper.new(mappings, runner)
      mapper = Test::Mapper.new(mappings, hook_wrapper)
      compile(gherkin_documents, mapper)
      self
    end

    module Test
      class HookWrapper
        include Cucumber.initializer(:mappings, :receiver)

        def test_case(test_case)
          collector = HookCollector.new(test_case)
          mappings.hooks(test_case, collector)
          test_case.
            prepend_steps(collector.before_steps).
            append_steps(collector.after_steps).
            describe_to(receiver)
        end

        class HookCollector
          attr_reader :before_steps, :after_steps

          def initialize(test_case)
            @test_case = test_case
            @before_steps, @after_steps = [], []
          end

          def before(&block)
            before_steps << Hook.new(@test_case, &block)
          end

          def after(&block)
            after_steps << Hook.new(@test_case, &block)
          end
        end

        class Hook
          def initialize(test_case, &block)
            @test_case = test_case
            @mapping = Mapping.new(&block)
          end

          def describe_to(visitor, *args)
            visitor.test_step(self, *args)
          end

          def describe_source_to(visitor, *args)
            @test_case.describe_source_to(visitor, *args)
            visitor.hook(self, *args)
          end

          def execute
            @mapping.execute
          end

          def skip
            @mapping.skip
          end

        end
      end
    end

  end
end
