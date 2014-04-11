require 'spec_helper'

module Deface
  module Actions
    describe RemoveFromAttributes do
      include_context "mock Rails.application"
      before { Dummy.all.clear }

      describe "with a single remove_from_attributes override (containing only text) defined" do
        before { Deface::Override.new(:virtual_path => "posts/index", :name => "Posts#index", :remove_from_attributes => 'img', 
                                        :attributes => {:class => 'pretty'}) }
        let(:source) { "<img class=\"pretty button\" src=\"path/to/button.png\">" }

        it "should return modified source" do
          attrs = attributes_to_sorted_array(Dummy.apply(source, {:virtual_path => "posts/index"}))

          attrs["class"].value.should == "button"
        end
      end

      describe "with a single remove_from_attributes override (containing erb) defined" do
        before { Deface::Override.new(:virtual_path => "posts/index", :name => "Posts#index", :remove_from_attributes => 'img', 
                                        :attributes => {:class => '<%= add_class %>'}) }
        let(:source) { "<img class=\"button <%= add_class %>\" src=\"path/to/button.png\">" }

        it "should return modified source" do
          attrs = attributes_to_sorted_array(Dummy.apply(source, {:virtual_path => "posts/index"}))

          attrs["class"].value.should == "button"
          attrs["src"].value.should == "path/to/button.png"
        end
      end

      describe "with a single remove_from_attributes override (containing erb) defined using pseudo attribute name" do
        before { Deface::Override.new(:virtual_path => "posts/index", :name => "Posts#index", :remove_from_attributes => 'img', 
                                        :attributes => {'data-erb-class' => '<%= add_class %>'}) }
        let(:source) { "<img class=\"button <%= add_class %>\" src=\"path/to/button.png\">" }

        it "should return modified source" do
          attrs = attributes_to_sorted_array(Dummy.apply(source, {:virtual_path => "posts/index"}))

          attrs["class"].value.should == "button"
          attrs["src"].value.should == "path/to/button.png"
        end
      end

      describe "with a single remove_from_attributes override (containing only text) defined where value is not present in attribute" do
        before { Deface::Override.new(:virtual_path => "posts/index", :name => "Posts#index", :remove_from_attributes => 'img', 
                                        :attributes => {:class => 'pretty'}) }
        let(:source) { "<img class=\"button\" src=\"path/to/button.png\">" }

        it "should return unmodified source" do
          Dummy.apply(source, {:virtual_path => "posts/index"}).should == "<img class=\"button\" src=\"path/to/button.png\">" 
        end
      end

      describe "with a single remove_from_attributes override (containing only text) defined where value is not present in attribute" do
        before { Deface::Override.new(:virtual_path => "posts/index", :name => "Posts#index", :remove_from_attributes => 'img', 
                                        :attributes => {:class => 'pretty'}) }
        let(:source) { "<img src=\"path/to/button.png\">" }

        it "should return unmodified source" do
          Dummy.apply(source, {:virtual_path => "posts/index"}).should == "<img src=\"path/to/button.png\">" 
        end
      end

      describe "with a single remove_from_attributes override (containing erb) defined targetting an existing pseudo attribute" do
        before { Deface::Override.new(:virtual_path => "posts/index", :name => "Posts#index", :remove_from_attributes => 'img', 
                                        :attributes => {:class => '<%= get_some_other_class %>'}) }
        let(:source) { "<img class=\"<%= get_class %> <%= get_some_other_class %>\" src=\"path/to/button.png\">" }

        it "should return modified source" do
          attrs = attributes_to_sorted_array(Dummy.apply(source, {:virtual_path => "posts/index"}))

          attrs["class"].value.should == "<%= get_class %>"
          attrs["src"].value.should == "path/to/button.png"
        end
      end
    end
  end
end
