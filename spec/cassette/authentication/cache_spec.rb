# frozen_string_literal: true

describe Cassette::Authentication::Cache do
  subject(:cache) { described_class.new(Logger.new('/dev/null')) }

  describe '#fetch_authentication' do
    subject(:fetch_authentication) do
      cache.fetch_authentication(ticket, service, &block)
    end

    def second_call
      cache.fetch_authentication(ticket, service, &other_block)
    end

    def call_with_other_service
      cache.fetch_authentication(ticket, other_service, &other_block)
    end

    let(:ticket) { 'ticket' }

    let(:service) { 'lala' }
    let(:other_service) { 'popo' }

    let(:block) { -> { 1 } }
    let(:other_block) { -> { 2 } }

    before { cache.fetch_authentication(ticket, service, &block) }

    it { is_expected.to eq(1) }

    context 'when for a second time' do
      it { expect(second_call).to eq(1) }

      it do
        expect(other_block).not_to receive(:call)
        second_call
      end

      context 'when calling with a different service' do
        it { expect(call_with_other_service).to eq(2) }
      end
    end

    it 'uses the cache store set in configuration' do
      # setup
      global_cache = instance_double(described_class, 'cache_store')
      Cassette.cache_backend = global_cache

      # exercise
      auth_cache = described_class.new(Logger.new('/dev/null'))

      expect(auth_cache.backend).to eq(global_cache)

      # tear down
      Cassette.cache_backend = nil
    end
  end
end
