describe OptionalRedisCacheStore do
  subject { described_class.new(namespace: 'test') }

  before do
    subject.configure(url: ENV.fetch('CACHE_STORE_HOST', nil))
  end

  describe '#set' do
    let(:key) { 'setkey' }
    let(:value) { double }

    it 'should pass the key/value to the redis_store' do
      expect(subject.redis_store).to receive(:set).with(key, value, 0).once
      subject.set(key, value)
    end

    it 'is aliased to #write' do
      expect(subject.redis_store).to receive(:set).with(key, value, 0).once
      subject.write(key, value)
    end

    context 'when an error occurs' do
      before do
        allow(subject.redis_store).to receive(:set).and_raise(StandardError)
      end
      it 'does not raise error' do
        expect{ subject.set(key, value) }.not_to raise_error
      end
    end
  end

  describe '#get' do
    let(:key) { 'getkey' }
    it 'requests the key from the redis_store' do
      expect(subject.redis_store).to receive(:get).with(key, 0).once
      subject.get(key)
    end
    context 'when an error occurs' do
      before do
        allow(subject.redis_store).to receive(:get).and_raise(StandardError)
      end
      it 'returns nil' do
        expect(subject.get(key)).to be nil
      end
    end
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
    let(:key) { 'remove_key' }
    it 'should pass the key to the redis_store' do
      expect(subject.redis_store).to receive(:remove).with(key).once
      subject.remove(key)
    end
    context 'when an error occurs' do
      before do
        allow(subject.redis_store).to receive(:remove).and_raise(StandardError)
      end
      it 'does not raise error' do
        expect{ subject.remove(key) }.not_to raise_error
      end
    end
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
