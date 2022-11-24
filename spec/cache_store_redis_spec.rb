# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples '#set' do |method_name|
  context 'expires_in' do
    let(:key) { SecureRandom.uuid }
    let(:value) { 'SomeValue' }

    it 'will always set a default TTL if one is not provided' do
      expect_any_instance_of(Redis).to receive(:set).with("test:#{key}", "\"#{value}\"")
      expect_any_instance_of(Redis).to receive(:expire).with("test:#{key}", 3_600)
      subject.public_send(method_name, key, value)
    end

    it 'will always set a default TTL if an invalid one is provided' do
      expect_any_instance_of(Redis).to receive(:set).with("test:#{key}", "\"#{value}\"")
      expect_any_instance_of(Redis).to receive(:expire).with("test:#{key}", 3_600)
      subject.public_send(method_name, key, value, -200)
    end

    it 'will always set a default TTL if an invalid one is provided' do
      expect_any_instance_of(Redis).to receive(:set).with("test:#{key}", "\"#{value}\"")
      expect_any_instance_of(Redis).to receive(:expire).with("test:#{key}", 3_600)
      subject.public_send(method_name, key, value, 0.456)
    end

    it 'will always force the TTL to be an integer' do
      expect_any_instance_of(Redis).to receive(:set).with("test:#{key}", "\"#{value}\"")
      expect_any_instance_of(Redis).to receive(:expire).with("test:#{key}", 20)
      subject.public_send(method_name, key, value, 20.123)
    end
  end

  it 'should add a string to the cache store and retrieve it' do
    key = SecureRandom.uuid
    value = 'value123'
    subject.public_send(method_name, key, value)

    v = subject.get(key)

    expect(v).to eq(value)
  end

  it 'should add an object to the cache store and retrieve it' do
    key = SecureRandom.uuid
    value = TestObject.new
    value.text = 'abc123'
    value.numeric = 123

    subject.public_send(method_name, key, value)

    v = subject.get(key)

    expect(v.class).to eq(TestObject)
    expect(v.text).to eq(value.text)
    expect(v.numeric).to eq(value.numeric)
  end

  it 'should run the hydration block when the requested key does not exist in the cache' do
    key = SecureRandom.uuid

    v = subject.get(key) do
      value = TestObject.new
      value.text = 'abc123'
      value.numeric = 123
      value
    end

    expect(v.class).to eq(TestObject)
    expect(v.text).to eq('abc123')
    expect(v.numeric).to eq(123)

    v2 = subject.get(key)
    expect(v2.class).to eq(TestObject)
    expect(v2.text).to eq('abc123')
    expect(v2.numeric).to eq(123)
  end

  context 'when set value has expired' do
    let(:key  ) { SecureRandom.uuid }
    let(:value) { '123'             }

    before :each do
      subject.public_send(method_name, key, value, 1)
      sleep(1.2)  # TODO: find a way to remove this by stubbing the Redis expire mechanism
    end

    it 'returns nil' do
      expect(subject.get(key)).to be_nil
    end
  end

  context 'when namespaced' do
    let(:key  ) { 'name' }
    let(:value) { 'Tom'  }

    subject { described_class.new('myname') }

    it 'sets the value' do
      subject.public_send(method_name, key, value)

      expect(subject.get(key)).to eq(value)
    end

    context 'when key already exists' do
      let(:new_value) { 'Peter' }
      before { subject.public_send(method_name, key, value) }

      it 'updates the item' do
        subject.public_send(method_name, key, new_value)

        expect(subject.get(key)).to eq(new_value)
      end
    end
  end
end

RSpec.shared_examples '#get' do |method_name|
  let(:value) { 'value' }
  let(:key) { 'getkey' }

  it 'runs the hyrdation block when the value is not in the cache' do
    v = subject.public_send(method_name, key) do
      value
    end

    expect(subject.public_send(method_name, key)).to eq v
  end

  context 'when the value in the store is empty string' do
    let(:value) { '' }

    it 'does not attempt to deserialize' do
      subject.set(key, value)
      expect(subject).to_not receive(:deserialize)
      expect(subject.public_send(method_name, key)).to be nil
    end
  end
end

RSpec.shared_examples '#remove' do |method_name|
  context 'when the value exists' do
    let(:key  ) { SecureRandom.uuid }
    let(:value) { '123'             }

    before { subject.set(key, value) }

    it 'removes that value' do
      expect(subject.exist?(key)).to be true

      subject.public_send(method_name, key)

      expect(subject.exist?(key)).to be false
    end
  end

  context 'when the value does no exist' do
    let(:key) { SecureRandom.uuid }

    it 'does not raise an exception' do
      expect { subject.public_send(method_name, key) }.to_not raise_error
    end
  end
end

describe RedisCacheStore do
  subject { described_class.new('test') }

  before do
    subject.configure(url: ENV.fetch('REDIS_URL'))
  end

  after :each do
    subject.with_client &:flushdb
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

  describe '#exists?' do
    context 'when a key does not exist' do
      let(:key) { SecureRandom.uuid }

      it 'returns false' do
        expect(subject.exist?(key)).to be false
      end
    end

    context 'when a key exists' do
      let(:key) { SecureRandom.uuid }

      before { subject.set(key, '123') }

      it 'returns true ' do
        expect(subject.exist?(key)).to be true
      end
    end
  end

  describe '#remove' do
    it_behaves_like '#remove', 'remove'
  end

  describe '#delete' do
    it_behaves_like '#remove', 'delete'
  end

  describe '#ping' do
    it 'pings the cache store' do
      expect(subject.ping).to eq 'PONG'
    end
  end
end
