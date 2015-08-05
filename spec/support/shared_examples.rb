shared_examples 'with --naginatafile' do
  let(:default_options) { {:verbose => true, :force => true} }
  before {
    naginatafile <<-EOS
      nagios_server 'root@localhost1'
    EOS
    Dir.chdir tmp # moves to the outside if the project
    naginata "#{args.join(' ')} --naginatafile #{app('Naginatafile')}", options
  }
  it "exits with exit code 0" do
    expect(exitstatus).to eq 0
  end
  it "returns expected output" do
    r = (expected_out.is_a? String) ? Regexp.new(expected_out) : expected_out
    expect(out).to match r
  end
end

shared_examples 'with setting NAGINATAFILE' do
  let(:default_options) { {:verbose => true} }
  before {
    naginatafile <<-EOS
      nagios_server 'root@localhost1'
    EOS
    Dir.chdir tmp # moves to the outside if the project
    ENV['NAGINATAFILE'] = app('Naginatafile').to_s
    naginata args.join(' '), options
  }
  it "exits with exit code 0" do
    expect(exitstatus).to eq 0
  end
  it "returns expected output" do
    r = (expected_out.is_a? String) ? Regexp.new(expected_out) : expected_out
    expect(out).to match r
  end
end

shared_examples 'with ~/.naginata/Naginatafile' do
  let(:default_options) { {:verbose => true} }
  before {
    naginatafile <<-EOS
      nagios_server 'root@localhost1'
    EOS
    Dir.chdir tmp # moves to the outside if the project
    FileUtils.mkdir_p 'dummyhome/.naginata'
    FileUtils.move app('Naginatafile'), 'dummyhome/.naginata/Naginatafile'
    ENV['HOME'] = File.expand_path('dummyhome')
    naginata args.join(' '), options
  }
  it "exits with exit code 0" do
    expect(exitstatus).to eq 0
  end
  it "returns expected output" do
    r = (expected_out.is_a? String) ? Regexp.new(expected_out) : expected_out
    expect(out).to match r
  end
end
