require 'spec_helper'

describe 'naginata version' do

  describe 'version' do
    before { naginata :version }
    it "prints version" do
      expect(exitstatus).to eq 0
      expect(err).to eq ''
      expect(out).to match /^Naginata version \d+\.\d+\.\d+$/
    end
  end

  describe '--version' do
    before { naginata '', version: true }
    it "prints version" do
      expect(exitstatus).to eq 0
      expect(err).to eq ''
      expect(out).to match /^Naginata version \d+\.\d+\.\d+$/
    end
  end
end
