require 'spec_helper'

module Deface
  module Actions
    describe SetAttributes do
      include_context "mock Rails.application"
      before { Dummy.all.clear }

      describe "with a single set_attributes override (containing only text) defined" do
        before { Deface::Override.new(:virtual_path => "posts/index", :name => "Posts#index", :set_attributes => 'img', 
                                        :attributes => {:class => 'pretty', :alt => 'something interesting'}) }
        let(:source) { "<img class=\"button\" src=\"path/to/button.png\">" }

        it "should return modified source" do
          attrs = attributes_to_sorted_array(Dummy.apply(source, {:virtual_path => "posts/index"}))

          attrs["class"].value.should == "pretty"
          attrs["alt"].value.should == "something interesting"
          attrs["src"].value.should == "path/to/button.png"
        end
      end

      describe "with a single set_attributes override (containing erb) defined" do
        before { Deface::Override.new(:virtual_path => "posts/index", :name => "Posts#index", :set_attributes => 'img', 
                                        :attributes => {:class => 'pretty', 'data-erb-alt' => '<%= something_interesting %>'}) }
        let(:source) { "<img class=\"button\" src=\"path/to/button.png\">" }

        it "should return modified source" do
          attrs = attributes_to_sorted_array(Dummy.apply(source, {:virtual_path => "posts/index"}))

          attrs["class"].value.should == "pretty"
          attrs["alt"].value.should == "<%= something_interesting %>"
          attrs["src"].value.should == "path/to/button.png"
        end
      end

      describe "with a single set_attributes override (containing erb) defined targetting an existing pseudo attribute" do
        before { Deface::Override.new(:virtual_path => "posts/index", :name => "Posts#index", :set_attributes => 'img', 
                                        :attributes => {:class => '<%= get_some_other_class %>', :alt => 'something interesting'}) }
        let(:source) { "<img class=\"<%= get_class %>\" src=\"path/to/button.png\">" }

        it "should return modified source" do
          attrs = attributes_to_sorted_array(Dummy.apply(source, {:virtual_path => "posts/index"}))

          attrs["class"].value.should == "<%= get_some_other_class %>"
          attrs["alt"].value.should == "something interesting"
          attrs["src"].value.should == "path/to/button.png"
        end
      end

      describe "with a single set_attributes override (containing a pseudo attribute with erb) defined targetting an existing pseudo attribute" do
        before { Deface::Override.new(:virtual_path => "posts/index", :name => "Posts#index", :set_attributes => 'img', 
                                        :attributes => {'class' => '<%= hello_world %>'}) }
        let(:source) { "<div><img class=\"<%= hello_moon %>\" src=\"path/to/button.png\"></div>" }

        it "should return modified source" do
          tag = Nokogiri::HTML::DocumentFragment.parse(Dummy.apply(source, {:virtual_path => "posts/index"}).gsub("\n", ""))
          tag = tag.css('img').first
          tag.attributes['src'].value.should eq "path/to/button.png"
          tag.attributes['class'].value.should eq "<%= hello_world %>"
        end
      end
    end
  end
end
