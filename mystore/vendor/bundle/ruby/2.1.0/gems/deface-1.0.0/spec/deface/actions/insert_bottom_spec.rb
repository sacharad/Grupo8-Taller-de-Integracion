require 'spec_helper'

module Deface
  module Actions
    describe InsertBottom do
      include_context "mock Rails.application"
      before { Dummy.all.clear }

      describe "with a single insert_bottom override defined" do
        before { Deface::Override.new(:virtual_path => "posts/index", :name => "Posts#index", :insert_bottom => "ul", :text => "<li>I'm always last</li>") }
        let(:source) { "<ul><li>first</li><li>second</li><li>third</li></ul>" }

        it "should return modified source" do
          Dummy.apply(source, {:virtual_path => "posts/index"}).gsub("\n", "").should == "<ul><li>first</li><li>second</li><li>third</li><li>I'm always last</li></ul>"
        end
      end

      describe "with a single insert_bottom override defined when targetted elemenet has no children" do
        before { Deface::Override.new(:virtual_path => "posts/index", :name => "Posts#index", :insert_bottom => "ul", :text => "<li>I'm always last</li>") }
        let(:source) { "<ul></ul>" }

        it "should return modified source" do
          Dummy.apply(source, {:virtual_path => "posts/index"}).gsub("\n", "").should == "<ul><li>I'm always last</li></ul>"
        end
      end
    end
  end
end
