require 'cucumber/core/ast/examples_table'

module Cucumber::Core::Ast
  describe ExamplesTable do
    describe ExamplesTable::Row do

      describe "expanding a string" do
        context "when an argument matches" do
          row = ExamplesTable::Row.new('arg' => 'replacement')
          text = 'this <arg> a test'
          it "replaces the argument with the value from the row" do
            row.expand(text).should == 'this replacement a test'
          end
        end

        context "when the replacement value is nil" do
          row = ExamplesTable::Row.new('color' => nil)
          text = 'a <color> cucumber'
          it "uses an empty string for the replacement" do
            row.expand(text).should == 'a  cucumber'
          end
        end

        context "when an argument does not match" do
          row = ExamplesTable::Row.new('x' => '1', 'y' => '2')
          text = 'foo <x> bar <z>'
          it "ignores the arguments that do not match" do
            row.expand(text).should == 'foo 1 bar <z>'
          end
        end
      end

    end
  end
end
