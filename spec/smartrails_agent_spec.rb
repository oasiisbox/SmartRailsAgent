# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SmartRailsAgent do
  it 'has a version number' do
    expect(SmartRailsAgent::VERSION).not_to be_nil
    expect(SmartRailsAgent::VERSION).to match(/\d+\.\d+\.\d+/)
  end

  describe '.configuration' do
    it 'returns a Configuration instance' do
      expect(SmartRailsAgent.configuration).to be_a(SmartRailsAgent::Configuration)
    end

    it 'has default values' do
      # Reset configuration for clean test
      SmartRailsAgent.instance_variable_set(:@configuration, nil)

      config = SmartRailsAgent.configuration
      expect(config.default_provider).to eq(:openai)
      expect(config.api_keys).to eq({})
      expect(config.endpoints).to eq({})
      expect(config.timeout).to eq(30)
    end
  end

  describe '.configure' do
    it 'allows configuration via block' do
      SmartRailsAgent.configure do |config|
        config.default_provider = :ollama
        config.timeout = 60
      end

      config = SmartRailsAgent.configuration
      expect(config.default_provider).to eq(:ollama)
      expect(config.timeout).to eq(60)
    end
  end

  describe '.chat' do
    let(:mock_provider) { instance_double('Provider') }
    let(:mock_llm) { instance_double(SmartRailsAgent::LLM) }

    before do
      allow(SmartRailsAgent::Providers::OpenAI).to receive(:new).and_return(mock_provider)
      allow(SmartRailsAgent::LLM).to receive(:new).and_return(mock_llm)
    end

    it 'creates an LLM instance and calls chat' do
      expect(mock_llm).to receive(:chat).with('Hello')
      SmartRailsAgent.chat('Hello')
    end

    it 'uses specified provider' do
      expect(SmartRailsAgent::Providers::Ollama).to receive(:new).and_return(mock_provider)
      expect(SmartRailsAgent::LLM).to receive(:new).with(provider: mock_provider).and_return(mock_llm)
      expect(mock_llm).to receive(:chat).with('Hello')

      SmartRailsAgent.chat('Hello', provider: :ollama)
    end

    it 'raises error for unknown provider' do
      expect do
        SmartRailsAgent.chat('Hello', provider: :unknown)
      end.to raise_error(SmartRailsAgent::Error, 'Unknown provider: unknown')
    end
  end
end
