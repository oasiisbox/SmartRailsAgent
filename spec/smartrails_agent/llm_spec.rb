# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SmartRailsAgent::LLM do
  let(:mock_provider) { double('Provider') }
  let(:llm) { described_class.new(provider: mock_provider) }

  describe '#initialize' do
    it 'sets the provider' do
      expect(llm.provider).to eq(mock_provider)
    end
  end

  describe '#chat' do
    it 'calls provider chat method' do
      expect(mock_provider).to receive(:chat).with('Hello', temperature: 0.5)
      llm.chat('Hello', temperature: 0.5)
    end

    it 'raises error for nil message' do
      expect do
        llm.chat(nil)
      end.to raise_error(ArgumentError, 'Message cannot be nil or empty')
    end

    it 'raises error for empty message' do
      expect do
        llm.chat('   ')
      end.to raise_error(ArgumentError, 'Message cannot be nil or empty')
    end
  end

  describe '#stream_chat' do
    context 'when provider supports streaming' do
      before do
        allow(mock_provider).to receive(:respond_to?).with(:stream_chat).and_return(true)
      end

      it 'calls provider stream_chat method' do
        block = proc { |chunk| puts chunk }
        expect(mock_provider).to receive(:stream_chat).with('Hello', temperature: 0.5, &block)
        llm.stream_chat('Hello', temperature: 0.5, &block)
      end
    end

    context 'when provider does not support streaming' do
      before do
        allow(mock_provider).to receive(:respond_to?).with(:stream_chat).and_return(false)
        allow(mock_provider).to receive(:class).and_return(double(name: 'MockProvider'))
      end

      it 'raises error' do
        expect do
          llm.stream_chat('Hello') { |chunk| puts chunk }
        end.to raise_error(SmartRailsAgent::Error, /does not support streaming/)
      end
    end
  end

  describe '#models' do
    context 'when provider supports models' do
      before do
        allow(mock_provider).to receive(:respond_to?).with(:models).and_return(true)
      end

      it 'returns provider models' do
        expect(mock_provider).to receive(:models).and_return(%w[model1 model2])
        expect(llm.models).to eq(%w[model1 model2])
      end
    end

    context 'when provider does not support models' do
      before do
        allow(mock_provider).to receive(:respond_to?).with(:models).and_return(false)
      end

      it 'returns nil' do
        expect(llm.models).to be_nil
      end
    end
  end

  describe '#provider_info' do
    before do
      allow(mock_provider).to receive(:class).and_return(double(name: 'SmartRailsAgent::Providers::OpenAI'))
      allow(mock_provider).to receive(:respond_to?).with(:stream_chat).and_return(true)
      allow(mock_provider).to receive(:respond_to?).with(:models).and_return(false)
    end

    it 'returns provider information' do
      info = llm.provider_info
      expect(info[:name]).to eq('openai')
      expect(info[:streaming_supported]).to be true
      expect(info[:models_supported]).to be false
    end
  end
end
