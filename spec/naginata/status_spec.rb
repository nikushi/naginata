require 'spec_helper'

describe Naginata::Status do
  let(:status_dat_raw) { File.read(File.join(File.dirname(__FILE__), '../support/status.dat')) }

  describe '#save' do

    context '@status is nil' do
      subject { described_class.new.save }
      it { should eq false }
    end

    context '@status is present' do
      let(:context) { described_class.build(status_dat_raw, 'localhost') }
      let(:tempfile) { Tempfile.new('naginata_save') }
      before {
        allow(context).to receive(:path).and_return tempfile.path
        context.purge_cache
      }
      after {
        tempfile.close!
      }
      it "creates a file by marshal dump " do
        context.save
        expect(File.exist?(context.path)).to eq true
      end

      it "returns self" do
        expect(context.save).to be_a described_class
      end
    end
  end

  describe '#purge_cache' do

    let(:context) { described_class.build(status_dat_raw, 'localhost') }
    let(:tempfile) { Tempfile.new('naginata_purge_cache') }
    before {
      allow(context).to receive(:path).and_return tempfile.path
      context.purge_cache
    }
    after {
      tempfile.close!
    }
    before {
      context.purge_cache
    }
    it "context.path does not exist" do
      expect(File.exist?(context.path)).to eq false
    end
  end

  describe '#path' do
    let(:context) { described_class.new }
    subject { context.path }
    context "return path" do
      before {
        context.hostname = 'localhost'
        allow(described_class).to receive(:cache_dir).and_return '/path/to/cache/status'
      }
      it { should eq "/path/to/cache/status/localhost.status.dat" }
    end
    context "hostname is not set" do
      it { expect { subject }.to raise_error RuntimeError, "@hostname must be set" }
    end
  end

  describe '.build' do
    let(:subject) { described_class.build(status_dat_raw, 'localhost') }
    it { expect(subject.status).to be_a ::NagiosAnalyzer::Status }
    it { expect(subject.hostname).to eq 'localhost' }
  end

  describe '.cache_dir' do
    subject { described_class.cache_dir }
    before {
      allow(Dir).to receive(:pwd).and_return '/path'
    }
    context "home directory is set in ENV and it exists" do
      before {
        allow(ENV).to receive(:[]).with('HOME').and_return '/home/nikushi'
        allow(Dir).to receive(:exist?).with('/home/nikushi').and_return true
        expect(FileUtils).to receive(:mkdir_p).and_return '/home/nikushi/.naginata/cache/status'
      }
      it { should eq "/home/nikushi/.naginata/cache/status" }
    end

    context "home directory is set in ENV but it does not exist" do
      before {
        allow(ENV).to receive(:[]).with('HOME').and_return '/home/nikushi'
        allow(Dir).to receive(:exist?).with('/home/nikushi').and_return false
        expect(FileUtils).to receive(:mkdir_p).with('/path/.naginata/cache/status')
      }
      it { should eq "/path/.naginata/cache/status" }
    end

    context "home directory is not set in ENV" do
      before {
        allow(ENV).to receive(:[]).with('HOME').and_return nil
        expect(FileUtils).to receive(:mkdir_p).with('/path/.naginata/cache/status')
      }
      it { should eq "/path/.naginata/cache/status" }
    end
  end
  
  describe '.find' do
    pending
  end

end

