require 'spec_helper'
require 'nagip/configuration/service'

module Nagip
  class Configuration
    describe Service do
      let(:service) { described_class.new(description, host: hostname, on: nagios) }
      let(:description) { 'cpu' }
      let(:hostname) { 'router1' }
      let(:nagios) { 'nagios1' }

      describe ".new" do
        subject { service } 
        it { should be_a described_class }
      end

      #describe "#to_s" do
      #  subject { service.to_s }
      #  it { should eq description }
      #end

      describe "#hostname" do
        subject { service.hostname }
        it { should eq hostname }
      end

      describe "#description" do
        subject { service.description }
        it { should eq description }
      end

      describe "#nagios" do
        subject { service.nagios }
        it { should eq nagios }
      end

    end
  end
end
 
