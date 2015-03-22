require 'spec_helper'
require 'nagip/configuration'

describe Nagip::Configuration do
  let(:config) { described_class.new }

  describe ".new" do
    it 'accepts initial hash' do
      configuration = described_class.new(custom: 'value')
      expect(configuration.fetch(:custom)).to eq('value')
    end 
  end

  describe '.env' do
    it 'is a global accessor to a single instance' do
      described_class.env.set(:test, true)
      expect(described_class.env.fetch(:test)).to be_truthy
    end 
  end 

  describe 'setting and fetching' do
    subject { config.fetch(:key, :default) }

    context 'value is set' do
      before do
        config.set(:key, :value)
      end

      it 'returns the set value' do
        expect(subject).to eq :value
      end
    end

    context 'set_if_empty' do
      it 'sets the value when none is present' do
        config.set_if_empty(:key, :value)
        expect(subject).to eq :value
      end

      it 'does not overwrite the value' do
        config.set(:key, :value)
        config.set_if_empty(:key, :update)
        expect(subject).to eq :value
      end
    end

    context 'value is not set' do
      it 'returns the default value' do
        expect(subject).to eq :default
      end
    end

    context 'block is passed to fetch' do
      subject { config.fetch(:key, :default) { "value from block" } }

      it 'returns the block value' do
        expect(subject).to eq "value from block"
      end
    end
  end

  describe '#keys' do
    subject { config.keys }

    before do
      config.set(:key1, :value1)
      config.set(:key2, :value2)
    end 

    it 'returns all set keys' do
      expect(subject).to match_array [:key1, :key2]
    end 
  end

  describe '#nagios_servers' do
    subject { config.nagios_servers }
    before {
      expect(Nagip::Configuration::NagiosServer).to receive(:new) { 'mock' }
      config.nagios_server('name1')
    }
    it 'returns all nagios servers' do
      expect(subject.count).to eq 1
    end
  end

  describe '#host' do
    subject { config.services }

    context 'call without :on options' do
      it { expect { config.host('name1') }.to raise_error } 
    end

    context 'call with options' do
      let(:host) { 'name1' }
      let(:nagios) { 'nagios-server-1' }
      let(:stub) { 'stub' }

      context 'call with host and on: option' do
        before {
          expect(Nagip::Configuration::Host).to receive(:new).with(host, on: nagios) { stub }
          config.host(host, on: nagios)
        }
        it { expect(subject.count).to eq 1 }
        it { expect(subject.first).to eq stub }
      end

      context 'call with host and on: and services: options' do
        let(:services) { ['cpu', 'mem', 'loadavg'] }
        before {
          expect(Nagip::Configuration::Host).to receive(:new).with(host, on: nagios) { stub }
          services.each do |s|
            expect(Nagip::Configuration::Service).to receive(:new).with(s, host: host, on: nagios).once { stub }
          end
          config.host(host, on: nagios, services: services)
        }
        it { expect(subject.count).to eq 4 } # host cpu mem loadavg
      end
    end
  end

  describe 'setting the backend' do
    it 'by default, is SSHKit' do
      expect(config.backend).to eq SSHKit
    end
  end

  describe "ssh_options for Netssh" do
    it 'merges them with the :ssh_options variable' do
      config.set :format, :pretty
      config.set :log_level, :debug
      config.set :ssh_options, { user: 'albert' }
      SSHKit::Backend::Netssh.configure do |ssh| ssh.ssh_options = { key: '/path/to/key' } end
      config.configure_backend
      expect(config.backend.config.backend.config.ssh_options).to eq({ user: 'albert', key: '/path/to/key' })
    end
  end

end
