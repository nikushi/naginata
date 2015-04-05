require 'spec_helper'

describe 'naginata init' do
  describe 'no argments and no options' do

    context "writes Naginatafile" do
      before { naginata :init }
      it "creates Naginatafile" do
        expect(out).to eq "Writing new Naginatafile to #{app('Naginatafile')}"
        expect(exitstatus).to eq 0
        expect(File.exist?(app("Naginatafile"))).to eq true
      end
    end

    context "Naginatafile already exists" do
      before {
        naginata :init
        naginata :init
      }
      it "exits with error" do
        expect(out).to eq "Naginatafile already exists at #{app('Naginatafile')}"
        expect(exitstatus).to eq 1
      end
    end

  end
end
