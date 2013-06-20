require 'cucumber/core'
require 'cucumber/core/compiler'
require 'cucumber/core/generates_gherkin'

module Cucumber::Core
  describe Compiler do
    include GeneratesGherkin
    include Cucumber::Core

    it "compiles a scenario outline to test cases" do
      feature = gherkin do
        feature do
          scenario_outline do
            step 'passing <arg>'
            step 'passing'

            examples do
              row 'arg'
              row '1'
              row '2'
            end

            examples do
              row 'arg'
              row 'a'
            end
          end
        end
      end
      suite = compile([parse_gherkin(feature)])
      visitor = stub
      visitor.stub(:test_suite).and_yield
      visitor.should_receive(:test_case).exactly(3).times.and_yield
      visitor.should_receive(:test_step).exactly(6).times
      suite.describe_to(visitor)
    end

    it 'replaces arguments correctly when generating test steps' do
      feature = gherkin do
        feature do
          scenario_outline do
            step 'passing <arg1> with <arg2>'
            step 'as well as <arg3>'

            examples do
              row 'arg1', 'arg2', 'arg3'
              row '1',    '2',    '3'
            end
          end
        end
      end
      suite = compile([parse_gherkin(feature)])
      visitor = stub
      visitor.stub(:test_suite).and_yield
      visitor.stub(:test_case).and_yield
      visitor.should_receive(:test_step) do |step|
        source_visitor = stub.as_null_object
        source_visitor.should_receive(:step) do |step|
          step.name.should == 'passing x with y'
        end
      end.once.ordered
      visitor.should_receive(:test_step) do |step|
        source_visitor = stub.as_null_object
        source_visitor.should_receive(:step) do |step|
          step.name.should == 'as well as z'
        end
        step.describe_source_to(source_visitor)
      end.once.ordered
      suite.describe_to(visitor)
    end
  end
end

