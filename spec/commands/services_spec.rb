require 'spec_helper'

describe 'naginata services' do
  before {
    naginatafile <<-EOS
      nagios_server 'root@localhost1'
    EOS
  }

  describe 'with no hostpatterns and no --all-hosts option' do
    before { naginata :services }

    it "prints help" do
      expect(exitstatus).to eq 1
      expect(err).to eq ''
      expect(out).to match /^Usage:/
    end
  end

  describe 'with a hostpattern' do
    before { naginata "services web01.example.com" }

    it "prints table" do
      expect(exitstatus).to eq 0
      expect(err).to eq ''
      expect(out).to  match /^NAGIOS\s+HOST\s+SERVICE\s+STATUS\s+FLAGS\s+OUTPUT$/
    end
  end

  describe 'with multiple hostpatterns' do
    before { naginata "services web01 db01.example" }

    it "prints table" do
      expect(exitstatus).to eq 0
      expect(err).to eq ''
      expect(out).to  match /^NAGIOS\s+HOST\s+SERVICE\s+STATUS\s+FLAGS\s+OUTPUT$/
    end
  end

  describe 'with --all-hosts option' do
    before { naginata :services, all_hosts: true }
    it "prints table" do
      expect(exitstatus).to eq 0
      expect(err).to eq ''
      expect(out).to  match /^NAGIOS\s+HOST\s+SERVICE\s+STATUS\s+FLAGS\s+OUTPUT$/
    end
  end

  describe 'with --nagios option' do
    before { naginata :services, all_hosts: true, nagios: "nagios001,nagios002.example.com"}
    it "prints table" do
      expect(exitstatus).to eq 0
      expect(err).to eq ''
      expect(out).to  match /^NAGIOS\s+HOST\s+SERVICE\s+STATUS\s+FLAGS\s+OUTPUT$/
    end
  end

  describe 'with --service option' do
    before { naginata :services, all_hosts: true, service: "cpu,mem,loadavg"}
    it "prints table" do
      expect(exitstatus).to eq 0
      expect(err).to eq ''
      expect(out).to  match /^NAGIOS\s+HOST\s+SERVICE\s+STATUS\s+FLAGS\s+OUTPUT$/
    end
  end

  describe 'with --wide option' do
    before { naginata :services, all_hosts: true, wide: true}
    it "prints table" do
      expect(exitstatus).to eq 0
      expect(err).to eq ''
      expect(out).to  match /^NAGIOS\s+HOST\s+SERVICE\s+STATUS\s+FLAGS\s+OUTPUT$/
    end
  end

end
