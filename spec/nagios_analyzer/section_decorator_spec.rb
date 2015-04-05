require 'spec_helper'

module NagiosAnalyzer
  describe SectionDecorator do
    describe '#current_state' do
      subject { described_class.new(section).current_state }
      let(:section) { double("section", current_state: num) }

      context '0' do
        let(:num) { 0 }
        it { should eq 'OK' }
      end

      context '1' do
        let(:num) { 1 }
        it { should eq 'WARNING' }
      end

      context '2' do
        let(:num) { 2 }
        it { should eq 'CRITICAL' }
      end

      context '3' do
        let(:num) { 3 }
        it { should eq 'UNKNOWN' }
      end
    end
  end
end
