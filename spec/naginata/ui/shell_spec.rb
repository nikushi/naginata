module Naginata::UI
  describe Shell do
    describe 'initialize' do
      subject { described_class.new }
      it { should be_a described_class }
    end
  end
end
