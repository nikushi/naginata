require 'spec_helper'

describe 'naginata fetch' do

  before {
    naginatafile <<-EOS
      nagios_server 'root@localhost1'
      nagios_server 'root@localhost2'
    EOS
  }
  describe 'no argments and no options' do
    before { naginata :fetch }
    it "runs" do
      expect(exitstatus).to eq 0
      expect(err).to eq ''
      expect(out).to eq ''
    end
  end

  describe 'with --nagios --verbose' do
    before { naginata :fetch, nagios: 'localhost1', verbose: true }
    it "runs with infomation" do
      expect(exitstatus).to eq 0
      expect(err).to eq ''
      expect(out).to match /Saved into .+localhost1\.status\.dat/
      expect(out).not_to match /Saved into .+localhost2\.status\.dat/
    end
  end
end
