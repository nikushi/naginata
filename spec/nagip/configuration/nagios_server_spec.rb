require 'spec_helper'

module Nagip
  class Configuration
    describe NagiosServer do
      let(:server) { described_class.new('root@hostname:1234') }

      describe 'assigning properties' do

        before do
          server.with(properties)
        end

        context 'properties contains user' do
          let(:properties) { {user: 'tomc'} }

          it 'sets the user' do
            expect(server.user).to eq 'tomc'
          end

          it 'sets the netssh_options user' do
            expect(server.netssh_options[:user]).to eq 'tomc'
          end
        end

        context 'properties contains port' do
          let(:properties) { {port: 2222} }

          it 'sets the port' do
            expect(server.port).to eq 2222
          end
        end

        context 'properties contains key' do
          let(:properties) { {key: '/key'} }

          it 'adds the key' do
            expect(server.keys).to include '/key'
          end
        end

        context 'new properties' do
          let(:properties) { { foo: 5 } }

          it 'adds the properties' do
            expect(server.properties.foo).to eq 5
          end
        end

        context 'existing properties' do
          let(:properties) { { foo: 6 } }

          it 'keeps the existing properties' do
            expect(server.properties.foo).to eq 6
            server.properties.foo= 5
            expect(server.properties.foo).to eq 5
          end
        end
      end

      describe 'assign ssh_options' do
        let(:server) { described_class.new('user_name@hostname') }

        context 'defaults' do
          it 'forward agent' do
            expect(server.netssh_options[:forward_agent]).to eq true
          end
          it 'contains user' do
            expect(server.netssh_options[:user]).to eq 'user_name'
          end
        end

        context 'custom' do
          let(:properties) do
            { ssh_options: {
              user: 'another_user',
              keys: %w(/home/another_user/.ssh/id_rsa),
              forward_agent: false,
              } }
          end

          before do
            server.with(properties)
          end

          it 'not forward agent' do
            expect(server.netssh_options[:forward_agent]).to eq false
          end
          it 'contains correct user' do
            expect(server.netssh_options[:user]).to eq 'another_user'
          end
          it 'does not affect server user in host' do
            expect(server.user).to eq 'user_name'
          end
          it 'contains keys' do
            expect(server.netssh_options[:keys]).to eq %w(/home/another_user/.ssh/id_rsa)
          end
        end

      end

    end
  end
end
