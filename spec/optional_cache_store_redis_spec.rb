# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples '#set' do |method_name|
  let(:key) { 'setkey' }
  let(:value) { double }

  it 'should pass the key/value to the redis_store' do
    expect(subject.redis_store).to receive(:set).with(key, value, 0).once
    subject.public_send(method_name, key, value)
  end

  it 'is aliased to #write' do
    expect(subject.redis_store).to receive(:set).with(key, value, 0).once
    subject.public_send(method_name, key, value)
  end

  context 'when an error occurs' do
    before do
      allow(subject.redis_store).to receive(:set).and_raise(StandardError)
    end

    it 'does not raise error' do
      expect{ subject.public_send(method_name, key, value) }.not_to raise_error
    end
  end
end

RSpec.shared_examples '#get' do |method_name|
  let(:key) { 'getkey' }

  it 'requests the key from the redis_store' do
    expect(subject.redis_store).to receive(:get).with(key, 0).once
    subject.public_send(method_name, key)
  end

  context 'when an error occurs' do
    before do
      allow(subject.redis_store).to receive(:get).and_raise(StandardError)
    end

    it 'returns nil' do
      expect(subject.public_send(method_name, key)).to be nil
    end
  end
end

RSpec.shared_examples '#remove' do |method_name|
  let(:key) { 'remove_key' }

  it 'should pass the key to the redis_store' do
    expect(subject.redis_store).to receive(:remove).with(key).once
    subject.public_send(method_name, key)
  end

  context 'when an error occurs' do
    before do
      allow(subject.redis_store).to receive(:remove).and_raise(StandardError)
    end

    it 'does not raise error' do
      expect{ subject.public_send(method_name, key) }.not_to raise_error
    end
  end
end

describe OptionalRedisCacheStore do
  subject { described_class.new(namespace: 'test') }

  before do
    subject.configure(url: ENV.fetch('CACHE_STORE_HOST', nil))
  end

  describe '#set' do
    it_behaves_like '#set', 'set'
  end

  describe '#write' do
    it_behaves_like '#set', 'write'
  end

  describe '#get' do
    it_behaves_like '#get', 'get'
  end

  describe '#read' do
    it_behaves_like '#get', 'read'
  end

  describe '#exist?' do
    let(:key) { 'exists_key' }
    it 'should pass the key to the redis_store' do
      expect(subject.redis_store).to receive(:exist?).with(key).once
      subject.exist?(key)
    end
    context 'when an error occurs' do
      before do
        allow(subject.redis_store).to receive(:exist?).and_raise(StandardError)
      end
      it 'returns false' do
        expect(subject.exist?(key)).to be false
      end
    end
  end

  describe '#remove' do
    it_behaves_like '#remove', 'remove'
  end

  describe '#remove' do
    it_behaves_like '#remove', 'delete'
  end

  describe '#ping' do
    it 'should call ping on the redis_store' do
      expect(subject.redis_store).to receive(:ping).once
      subject.ping
    end
    context 'when an error occurs' do
      before do
        allow(subject.redis_store).to receive(:ping).and_raise(StandardError)
      end
      it 'returns false' do
        expect(subject.ping).to be false
      end
    end
  end
end
