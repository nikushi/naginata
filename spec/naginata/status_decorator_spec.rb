require 'spec_helper'

module Naginata
  describe StatusDecorator do

    describe '#hosts_table' do
      subject { described_class.new(status).hosts_table }
      let(:status) { double("status") }
      let(:section) { double("section") }
      before {
        allow(status).to receive(:host_items).and_return([section])
        allow(status).to receive(:nagios).and_return("mynagios")
        allow(section).to receive(:host_name).and_return("myhost")
        allow(section).to receive_message_chain("decorate.current_state").and_return("OK")
        allow(section).to receive_message_chain("decorate.flags_short").and_return("AC,PC,nt")
        allow(section).to receive(:plugin_output).and_return("PING_OK")
      }
      it "returns expected Array" do
        should eq [%w(mynagios myhost OK AC,PC,nt PING_OK)]
      end
    end

    describe '#services_table' do
      subject { described_class.new(status).services_table }
      let(:status) { double("status") }
      let(:section) { double("section") }
      before {
        allow(status).to receive(:service_items).and_return([section])
        allow(status).to receive(:nagios).and_return("mynagios")
        allow(section).to receive(:host_name).and_return("myhost")
        allow(section).to receive(:service_description).and_return("myservice")
        allow(section).to receive_message_chain("decorate.current_state").and_return("OK")
        allow(section).to receive_message_chain("decorate.flags_short").and_return("AC,PC,nt")
        allow(section).to receive(:plugin_output).and_return("PING_OK")
      }
      it "returns expected Array" do
        should eq [%w(mynagios myhost myservice OK AC,PC,nt PING_OK)]
      end
    end

  end
end
