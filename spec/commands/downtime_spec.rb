require 'spec_helper'

describe 'naginata downtime' do
  describe 'no argments and no options' do
    before { naginata :downtime }
    it "returns help" do
      expect(exitstatus).to eq 1
      expect(out).to match /^Usage:/
    end
  end

end
