require 'spec_helper'

describe Naginata do
  describe '.ui' do
    subject { described_class.ui }
    it { should be_a ::Naginata::UI::Shell }
  end
end
