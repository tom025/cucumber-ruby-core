require 'cucumber/core/gherkin/parser'
require 'cucumber/core/compiler'
require 'cucumber/core/test/runner'

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

    def map(gherkin_documents, mappings, runner)
      mapper = Mapper.new(mappings, runner)
      compile(gherkin_documents, mapper)
      self
    end

    def execute(gherkin_documents, mappings, report)
      runner = Test::Runner.new(report)
      map(gherkin_documents, mappings, runner)
      self
    end

    class Mapper
      include Cucumber.initializer(:mappings, :receiver)

      def test_case(test_case, &descend)
        descend.call(self)
        mapped_test_case = test_case.with_steps(mapped_steps)
        mapped_test_case.describe_to(receiver)
        @mapped_steps = nil
      end

      def test_step(test_step)
        mapped_steps << test_step.to_mapped_step(mappings)
      end

      private

      def mapped_steps
        @mapped_steps ||= []
      end

    end

  end
end
