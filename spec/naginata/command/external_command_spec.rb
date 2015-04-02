require 'spec_helper'

module Naginata::Command

  describe ExternalCommand do

    subject { described_class.send(action, *args) }
    let(:path) { '/path/to/nagios.cmd' }

    describe 'method_missing' do

      context 'call with action with two arguments' do
        let(:action) { :dummy }
        let(:args) { [:arg1, :arg2]  }
        it { expect { subject }.to raise_error ArgumentError, 'only one argment allowed' }
      end

      context 'undefined action is called' do
        let(:action) { :undefined }
        let(:args) { [{}] }
        it { expect { subject }.to raise_error ArgumentError, "action name #{action.to_s.upcase} is not implemented" }
      end

      context 'call action but without :path option' do
        let(:action) { :acknowledge_host_problem }
        let(:args) { [{}] }
        it { expect { subject }.to raise_error ArgumentError, ":path option is required" }
      end

    end

    describe 'timestamp' do
      context 'call action with ts: option' do
        let(:action) { :acknowledge_host_problem }
        let(:args) { [{path: path, ts: 1234}] }
        it { should match /^echo "\[1234\]/ }
      end
    end

    describe 'action which does not require options' do
      let(:action) { :disable_event_handlers }
      let(:args) { [{path: path, ts: 1234}] }
      it { should match /^echo "\[1234\] DISABLE_EVENT_HANDLERS" > #{path}/ }
    end

    describe 'action which requires options' do
      let(:action) { :disable_svc_notifications }
      let(:args) { [{path: path, ts: 1234, host_name: 'myserver', service_description: 'cpu'}] }
      it { should match /^echo "\[1234\] DISABLE_SVC_NOTIFICATIONS;myserver;cpu" > #{path}/ }
    end

  end

end
