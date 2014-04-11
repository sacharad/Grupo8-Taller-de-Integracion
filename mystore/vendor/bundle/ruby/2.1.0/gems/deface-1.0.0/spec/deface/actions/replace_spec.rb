require 'spec_helper'

module Deface
  module Actions
    describe Replace do
      include_context "mock Rails.application"
      before { Dummy.all.clear }

      describe "with a single replace override defined" do
        before { @override = Deface::Override.new(:virtual_path => "posts/index", :name => "Posts#index", :replace => "p", :text => "<h1>Argh!</h1>") }
        let(:source) { "<p>test</p>" }

        it "should return modified source" do
          Dummy.apply(source, {:virtual_path => "posts/index"}).should  == "<h1>Argh!</h1>"
          @override.failure.should be_false
        end
      end

      describe "with a single replace override with closing_selector defined" do
        before { @override = Deface::Override.new(:virtual_path => "posts/index", :name => "Posts#index", :replace => "h1", :closing_selector => "h2", :text => "<span>Argh!</span>") }
        let(:source) { "<h1>start</h1><p>some junk</p><div>more junk</div><h2>end</h2>" }

        it "should return modified source" do
          Dummy.apply(source, {:virtual_path => "posts/index"}).should == "<span>Argh!</span>"
          @override.failure.should be_false
        end
      end

      describe "with a single replace override with bad closing_selector defined" do
        before { @override = Deface::Override.new(:virtual_path => "posts/index", :name => "Posts#index", :replace => "h1", :closing_selector => "h3", :text => "<span>Argh!</span>") }
        let(:source) { "<h1>start</h1><p>some junk</p><div>more junk</div><h2>end</h2>" }

        it "should log error and return unmodified source" do
          Rails.logger.should_receive(:info).with(/failed to match with end selector/)
          Dummy.apply(source, {:virtual_path => "posts/index"}).should == source
          @override.failure.should be_true
        end
      end

      describe "with a single replace override with bad selector defined" do
        before { @override = Deface::Override.new(:virtual_path => "posts/index", :name => "Posts#index", :replace => "h3", :closing_selector => "h2", :text => "<span>Argh!</span>") }
        let(:source) { "<h1>start</h1><p>some junk</p><div>more junk</div><h2>end</h2>" }

        it "should log error and return unmodified source" do
          Rails.logger.should_receive(:info).with(/failed to match with starting selector/)
          Dummy.apply(source, {:virtual_path => "posts/index"}).should == source
          @override.failure.should be_true
        end
      end
    end
  end
end
