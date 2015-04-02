require 'spec_helper'

module Naginata
  class Configuration
    describe Filter do
      let(:available_nagios_servers) { [
        NagiosServer.new('nagios1'),
        NagiosServer.new('nagios2'),
        NagiosServer.new('nagios3'),
        NagiosServer.new('myserver1'),
        NagiosServer.new('myserver2'),
        NagiosServer.new('myserver3'),
      ] }
      let(:available_services) { [
        Host.new(                     'router1', on: 'nagios1'),
        Host.new(                     'router1', on: 'nagios1'),
        Service.new('web1-cpu',  host: 'web1',   on: 'nagios2'),
        Service.new('web1-disk', host: 'web1',   on: 'nagios2'),
        Service.new('db1-cpu',   host: 'db1',    on: 'nagios3'),
        Service.new('db1-disk',  host: 'db1',    on: 'nagios3'),
      ] }

      describe '#new' do
        it "won't create an invalid type of filter" do
          expect {
            f = described_class.new(:invalidtype)
          }.to raise_error RuntimeError
        end 

        context 'create an nagios_server filter' do
          it 'creates an null nagios_server filter' do
            expect(described_class.new(:nagios_server, :all).filter(available_nagios_servers)).to eq available_nagios_servers
          end 

          it 'creates an empty nagios_server filter' do
            expect(described_class.new(:nagios_server).filter(available_nagios_servers)).to be_empty
          end 

          it 'creates an empty host filter' do
            expect(described_class.new(:host).filter_service(available_services)).to  be_empty
          end 

          it 'creates an empty service filter' do
            expect(described_class.new(:service).filter_service(available_services)).to be_empty
          end 
        end
      end

      describe 'nagios filter' do
        it 'works with a single nagios' do
          set = described_class.new(:nagios_server, 'nagios1').filter(available_nagios_servers.first)
          expect(set.map(&:hostname)).to eq(%w{nagios1})
        end

        it 'returns all nagios matching a string' do
          set = Filter.new(:nagios_server, 'nagios1').filter(available_nagios_servers)
          expect(set.map(&:hostname)).to eq(%w{nagios1})
        end

        it 'returns all nagios matching a comma-separated string' do
          set = Filter.new(:nagios_server, 'nagios1,nagios3').filter(available_nagios_servers)
          expect(set.map(&:hostname)).to eq(%w{nagios1 nagios3})
        end

        it 'returns all nagios matching an array of strings' do
          set = Filter.new(:nagios_server, %w{nagios1 nagios3}).filter(available_nagios_servers)
          expect(set.map(&:hostname)).to eq(%w{nagios1 nagios3})
        end

        it 'returns all nagios matching regexp' do
          set = Filter.new(:nagios_server, 'nagios[13]$').filter(available_nagios_servers)
          expect(set.map(&:hostname)).to eq(%w{nagios1 nagios3})
        end

        it 'returns all nagios matching partially' do
          set = Filter.new(:nagios_server, 'nagios').filter(available_nagios_servers)
          expect(set.map(&:hostname)).to eq(%w{nagios1 nagios2 nagios3})
        end

      end

      describe 'service filter by nagios server name' do
        it 'works with a single nagios' do
          set = Filter.new(:nagios_server, 'nagios1').filter_service(available_services.first)
          expect(set.map(&:nagios)).to eq(%w{nagios1})
        end

        it 'returns all services matching a string' do
          set = Filter.new(:nagios_server, 'nagios1').filter_service(available_services)
          expect(set.map(&:nagios)).to eq(%w{nagios1 nagios1})
        end

        it 'returns all services being filtered by a comma-separated nagios names' do
          set = Filter.new(:nagios_server, 'nagios1,nagios3').filter_service(available_services)
          expect(set.map(&:nagios)).to eq(%w{nagios1 nagios1 nagios3 nagios3})
        end

        it 'returns all services being filtered by an array of nagios names' do
          set = Filter.new(:nagios_server, %w{nagios1 nagios3}).filter_service(available_services)
          expect(set.map(&:nagios)).to eq(%w{nagios1 nagios1 nagios3 nagios3})
        end

        it 'returns all services being filtered by nagios name regexp' do
          set = Filter.new(:nagios_server, 'nagios[13]$').filter_service(available_services)
          expect(set.map(&:nagios)).to eq(%w{nagios1 nagios1 nagios3 nagios3})
        end

        it 'returns all services being filtered by nagios name matching partially' do
          set = Filter.new(:nagios_server, 'gios2').filter_service(available_services)
          expect(set.map(&:nagios)).to eq(%w{nagios2 nagios2})
        end

      end

      describe 'service filter by host' do
        it 'works with a single host' do
          set = Filter.new(:host, 'router1').filter_service(available_services.first)
          expect(set.map(&:hostname)).to eq(%w{router1})
        end

        it 'returns all services matching a string' do
          set = Filter.new(:host, 'router1').filter_service(available_services)
          expect(set.map(&:hostname)).to eq(%w{router1 router1})
        end

        it 'returns all services being filtered by a comma-separated host names' do
          set = Filter.new(:host, 'router1,db1').filter_service(available_services)
          expect(set.map(&:hostname)).to eq(%w{router1 router1 db1 db1})
        end

        it 'returns all services being filtered by an array of host names' do
          set = Filter.new(:host, %w{router1 db1}).filter_service(available_services)
          expect(set.map(&:hostname)).to eq(%w{router1 router1 db1 db1})
        end

        it 'returns all services being filtered by host name regexp' do
          set = Filter.new(:host, '^router').filter_service(available_services)
          expect(set.map(&:hostname)).to eq(%w{router1 router1})
        end

        it 'returns all services being filtered by host name matching partially' do
          set = Filter.new(:host, 'outer').filter_service(available_services)
          expect(set.map(&:hostname)).to eq(%w{router1 router1})
        end
      end

      describe 'service filter by service' do
        it 'works with a single service' do
          set = Filter.new(:service, 'db1-disk').filter_service(available_services.last)
          expect(set.map(&:description)).to eq(%w{db1-disk})
        end

        it 'returns all services matching a string' do
          set = Filter.new(:service, 'web1-cpu').filter_service(available_services)
          expect(set.map(&:description)).to eq(%w{web1-cpu})
        end

        it 'returns all services being filtered by a comma-separated service' do
          set = Filter.new(:service, 'db1-cpu,db1-disk').filter_service(available_services)
          expect(set.map(&:description)).to eq(%w{db1-cpu db1-disk})
        end

        it 'returns all services being filtered by an array of service' do
          set = Filter.new(:service, %w{db1-cpu db1-disk}).filter_service(available_services)
          expect(set.map(&:description)).to eq(%w{db1-cpu db1-disk})
        end

        it 'returns all services being filtered by service regexp' do
          set = Filter.new(:service, '^web1').filter_service(available_services)
          expect(set.map(&:description)).to eq(%w{web1-cpu web1-disk})
        end

        it 'returns all services being filtered by service matching partially' do
          set = Filter.new(:service, 'web1').filter_service(available_services)
          expect(set.map(&:description)).to eq(%w{web1-cpu web1-disk})
        end

        it 'returns all services except Host(s)' do
          # Need refactor??
          set = Filter.new(:service, '.+').filter_service(available_services)
          expect(set.map(&:class).uniq).to eq [Service]
          expect(set.map(&:description)).to eq(%w{web1-cpu web1-disk db1-cpu db1-disk})
        end


      end
    end
  end
end
