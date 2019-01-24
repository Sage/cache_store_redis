describe RedisConnection do
  let(:config) { {} }

  subject do
    described_class.new(config)
  end

  describe '#initialize' do
    it 'creates a redis client' do
      expect(subject.client).to be_instance_of(Redis)
    end

    it 'sets a created timestamp' do
      Timecop.freeze(Time.now) do
        expect(subject.created).to eq(Time.now)
      end
    end
  end

  describe '#expired?' do
    context 'when created is nil' do
      it 'returns false' do
        subject.created = nil
        expect(subject.expired?).to eq(false)
      end
    end

    context 'when current time is greater than the created time + keep alive timeout' do
      it 'returns true' do
        subject.open

        Timecop.freeze(Time.now + 60) do
          expect(subject.expired?).to eq(true)
        end
      end
    end

    context 'when current time is less than the created time + keep alive timeout' do
      it 'returns false' do
        expect(subject.expired?).to eq(false)
      end
    end
  end

  describe '#open' do
    it 'ensures that .created is set' do
      subject.created = nil
      subject.open
      expect(subject.created).to_not be_nil
    end
  end

  describe '#close' do
    it 'sets created to nil' do
      subject.close
      expect(subject.created).to be_nil
    end

    it 'calls close on the Redis client' do
      expect(subject.client).to receive(:close)
      subject.close
    end
  end

  describe '#keep_alive_timeout' do
    it 'returns a default keep alive of 30.0' do
      expect(subject.keep_alive_timeout).to eq(30.0)
    end

    context 'when REDIS_KEEP_ALIVE_TIMEOUT is set' do
      before do
        ENV['REDIS_KEEP_ALIVE_TIMEOUT'] = "400"
      end

      it 'returns the value of REDIS_KEEP_ALIVE_TIMEOUT as a float' do
        expect(subject.keep_alive_timeout).to eq(400.0)
      end

      after do
        ENV['REDIS_KEEP_ALIVE_TIMEOUT'] = nil
      end
    end
  end
end
