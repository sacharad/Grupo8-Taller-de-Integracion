require 'spec_helper'
require 'deface/utils/failure_finder'

module Deface
  module Utils
    describe FailureFinder do
      include Deface::Utils::FailureFinder
      include Deface::TemplateHelper
      include_context "mock Rails.application"

      before do
        #stub view paths to be local spec/assets directory
        ActionController::Base.stub(:view_paths).and_return([File.join(File.dirname(__FILE__), '../..', "assets")])
      end

      context "given failing overrides" do
        before do
          Deface::Override.new(:virtual_path => "shared/_post", :name => "good", :remove => "p")
          Deface::Override.new(:virtual_path => "shared/_post", :name => "bad", :remove => "img")
        end

        context "overrides_by_virtual_path" do
          it "should load template and apply overrides" do
            fails = overrides_by_virtual_path('shared/_post')
            count = fails.group_by{ |o| !o.failure.nil? }

            count[true].size.should == 1
            count[true].first.name.should == 'bad'
            count[false].size.should == 1
            count[false].first.name.should == 'good'
          end

          it "should return nil for path virtual_path value" do
            silence_stream(STDOUT) do
              overrides_by_virtual_path('shared/_poster').should be_nil
            end
          end
        end

        context "output_results_by_virtual_path" do
          it "should return count of failed overrides for given path" do
            silence_stream(STDOUT) do
              output_results_by_virtual_path('shared/_post').should == 1
            end
          end
        end
      end

      context "given no failing overrides" do
        before do
          Deface::Override.new(:virtual_path => "shared/_post", :name => "good", :remove => "p")
        end

        context "overrides_by_virtual_path" do
          it "should load template and apply overrides" do
            fails = overrides_by_virtual_path('shared/_post')
            count = fails.group_by{ |o| !o.failure.nil? }

            count.key?('true').should be_false 
            count[false].size.should == 1
            count[false].first.name.should == 'good'
          end

        end

        context "output_results_by_virtual_path" do
          it "should return count of failed overrides for given path" do
            silence_stream(STDOUT) do
              output_results_by_virtual_path('shared/_post').should == 0
            end
          end
        end
      end
    end
  end
end
