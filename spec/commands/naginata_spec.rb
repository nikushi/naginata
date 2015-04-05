require 'spec_helper'

describe 'naginata' do
  context 'without no args and no options' do
    before { naginata '' }
    it "prints help" do
      expect(out).to match /^Commands:/
      expect(exitstatus).to eq 0
    end
  end
end
