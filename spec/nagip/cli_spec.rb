require 'nagip/cli'

describe Nagip::CLI do
  describe ".new" do
    it { expect(described_class.new).to be_a described_class }
  end
end
