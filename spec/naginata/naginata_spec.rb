require 'spec_helper'

describe Nagip do
  describe '.ui' do
    subject { described_class.ui }
    it { should be_a ::Nagip::UI::Shell }
  end
end
