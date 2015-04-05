require 'spec_helper'

describe 'naginata hosts' do
  before {
    naginatafile <<-EOS
      nagios_server 'root@nagios001.example.com'
      nagios_server 'root@nagios002.example.com'
    EOS
  }

  describe 'with no hostpatterns and no --all-hosts option' do
    before { naginata :hosts }

    it "prints help" do
      expect(exitstatus).to eq 1
      expect(err).to eq ''
      expect(out).to match /^Usage:/
    end
  end

  describe 'with a hostpattern' do
    before { naginata "hosts web01.example.com" }

    it "prints table" do
      expect(exitstatus).to eq 0
      expect(err).to eq ''
      expect(out).to  match /^NAGIOS\s+HOST\s+STATUS\s+FLAGS\s+OUTPUT$/
    end
  end

  describe 'with multiple hostpatterns' do
    before { naginata "hosts web01 db01.example" }

    it "prints table" do
      expect(exitstatus).to eq 0
      expect(err).to eq ''
      expect(out).to  match /^NAGIOS\s+HOST\s+STATUS\s+FLAGS\s+OUTPUT$/
    end
  end

  describe 'with --all-hosts option' do
    before { naginata :hosts, all_hosts: true }
    it "prints table" do
      expect(exitstatus).to eq 0
      expect(err).to eq ''
      expect(out).to  match /^NAGIOS\s+HOST\s+STATUS\s+FLAGS\s+OUTPUT$/
    end
  end

  describe 'with --nagios option' do
    before { naginata :hosts, all_hosts: true, nagios: "nagios001,nagios002.example.com"}
    it "prints table" do
      expect(exitstatus).to eq 0
      expect(err).to eq ''
      expect(out).to  match /^NAGIOS\s+HOST\s+STATUS\s+FLAGS\s+OUTPUT$/
    end
  end

end
