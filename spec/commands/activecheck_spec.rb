require 'spec_helper'

describe 'naginata activecheck' do
  describe 'no argments and no options' do
    before { naginata :activecheck}
    it "returns help" do
      expect(exitstatus).to eq 1
      expect(out).to match /^Usage:/
    end
  end

  describe 'check options' do
    before {
      naginatafile <<-EOS
        nagios_server 'root@localhost1'
      EOS
      naginata "activecheck #{patterns.join(' ')}", options
    }

    context 'without -e and -d' do
      let(:options) { {} }
      let(:patterns) { ['localhost1'] }
      it "exits with error" do
        expect(exitstatus).to eq 1
        expect(out).to eq ''
        expect(err).to eq 'Either --enable or --disable options is required'
      end
    end

    context 'with -e and -d' do
      let(:options) { {enable: true, disable: true} }
      let(:patterns) { [] }
      it "exits with error" do
        expect(exitstatus).to eq 1
        expect(out).to eq ''
        expect(err).to eq "Both --enable and --disable options can not be given"
      end
    end

    context 'without patterns and --all-hosts' do
      let(:options) { {enable: true} }
      let(:patterns) { [] }
      it "exits with error" do
        expect(exitstatus).to eq 1
        expect(out).to eq ''
        expect(err).to eq "At least one hostpattern must be given or use --all-hosts option"
      end
    end
  end

  %w(enable disable).each do |action|
    describe action do
      it_runs 'with --naginatafile' do
        let(:args) { %w(notification myserver) }
        let(:options) { { action.to_sym => true, :verbose => true, :force => true } }
        let(:expected_out) { 'Done' }
      end

      it_runs 'with setting NAGINATAFILE' do
        let(:args) { %w(notification myserver) }
        let(:options) { { action.to_sym => true, :verbose => true, :force => true } }
        let(:expected_out) { 'Done' }
      end

      it_runs 'with ~/.naginata/Naginatafile' do
        let(:args) { %w(notification myserver) }
        let(:options) { { action.to_sym => true, :verbose => true, :force => true } }
        let(:expected_out) { 'Done' }
      end

      describe 'target one host' do
        before {
          naginatafile <<-EOS
            nagios_server 'root@localhost1'
          EOS
          naginata "activecheck #{patterns.join(' ')}", options
        }
        let(:patterns) { %w(myserver) }
        let(:options) { {action.to_sym => true, :verbose => true, :force => true} }
        it "runs" do
          expect(exitstatus).to eq 0
          expect(out).to match /Done/
        end
      end

      describe 'target multiple hosts' do
        before {
          naginatafile <<-EOS
            nagios_server 'root@localhost1'
          EOS
          naginata "activecheck #{patterns.join(' ')}", options
        }
        let(:patterns) { %w(mydb1 myweb1) }
        let(:options) { {action.to_sym => true, :verbose => true, :force => true} }
        it "runs" do
          expect(exitstatus).to eq 0
          expect(out).to match /Done/
        end
      end

      describe 'target all hosts' do
        before {
          naginatafile <<-EOS
            nagios_server 'root@localhost1'
          EOS
          naginata "activecheck", options
        }
        let(:options) { {action.to_sym => true, :verbose => true, :force => true, :all_hosts => true} }
        it "runs" do
          expect(exitstatus).to eq 0
          expect(out).to match /Done/
        end
      end

      describe 'filter by one service' do
        before {
          naginatafile <<-EOS
            nagios_server 'root@localhost1'
          EOS
          naginata "activecheck", options
        }
        let(:options) { {action.to_sym => true, :verbose => true, :force => true, :all_hosts => true, services: "http"} }
        it "runs" do
          expect(exitstatus).to eq 0
          expect(out).to match /Done/
        end
      end

      describe 'filter by comman separated mutiple services' do
        before {
          naginatafile <<-EOS
            nagios_server 'root@localhost1'
          EOS
          naginata "activecheck", options
        }
        let(:options) { {action.to_sym => true, :verbose => true, :force => true, :all_hosts => true, services: "http,memory"} }
        it "runs" do
          expect(exitstatus).to eq 0
          expect(out).to match /Done/
        end
      end

      describe 'filter by comman separated nagios servers' do
        before {
          naginatafile <<-EOS
            nagios_server 'root@localhost1'
            nagios_server 'root@localhost2'
            nagios_server 'root@localhost3'
          EOS
          naginata "activecheck", options
        }
        let(:options) { {action.to_sym => true, :verbose => true, :force => true, :all_hosts => true, nagios: "lhost2,st3"} }
        it "runs" do
          expect(exitstatus).to eq 0
          expect(out).to match /Done/
          expect(out).not_to match /localhost1/
          expect(out).to match /localhost2/
          expect(out).to match /localhost3/
        end

      end
    end
  end
end
