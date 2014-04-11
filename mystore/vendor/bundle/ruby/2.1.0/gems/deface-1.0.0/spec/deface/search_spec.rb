require 'spec_helper'

module Deface
  describe Search do
    include_context "mock Rails.application"

    before(:each) do
      @override = Deface::Override.new(:virtual_path => "posts/index", :name => "Posts#index", :replace => "h1",
                                       :text => "<h1>Argh!</h1>")
    end

    describe "#find" do
      it "should find by virtual_path" do
        Deface::Override.find({:virtual_path => "posts/index"}).size.should == 1
        Deface::Override.find({:virtual_path => "/posts/index"}).size.should == 1
        Deface::Override.find({:virtual_path => "/posts/index.html"}).size.should == 1
        Deface::Override.find({:virtual_path => "posts/index.html"}).size.should == 1
      end

      it "should return empty array when no details hash passed" do
        Deface::Override.find({}).should == []
      end
    end

    describe "#find_using" do
      before do
        @override_partial = Deface::Override.new(:virtual_path => "posts/index", :name => "Posts#edit", :replace => "h1",
                                                 :partial => "shared/post")

        @override_template = Deface::Override.new(:virtual_path => "posts/index", :name => "Posts#show", :replace => "h1",
                                                  :template => "shared/person")
      end

      it "should find by virtual_path" do
        Deface::Override.find_using("shared/post").size.should == 1
        Deface::Override.find_using("shared/person").size.should == 1
      end

    end
  end
end
