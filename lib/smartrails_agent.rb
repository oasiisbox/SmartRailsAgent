# frozen_string_literal: true

require_relative 'smartrails_agent/version'
require_relative 'smartrails_agent/llm'
require_relative 'smartrails_agent/providers/openai'
require_relative 'smartrails_agent/providers/ollama'
require_relative 'smartrails_agent/providers/mistral'
require_relative 'smartrails_agent/providers/claude'

module SmartRailsAgent
  class Error < StandardError; end

  class Configuration
    attr_accessor :default_provider, :api_keys, :endpoints, :timeout

    def initialize
      @default_provider = :openai
      @api_keys = {}
      @endpoints = {}
      @timeout = 30
    end
  end

  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.chat(message, provider: nil, **options)
    provider_name = provider || configuration.default_provider
    provider_class = get_provider_class(provider_name)

    llm = LLM.new(provider: provider_class.new)
    llm.chat(message, **options)
  end

  def self.get_provider_class(provider_name)
    case provider_name.to_sym
    when :openai
      Providers::OpenAI
    when :ollama
      Providers::Ollama
    when :mistral
      Providers::Mistral
    when :claude
      Providers::Claude
    else
      raise Error, "Unknown provider: #{provider_name}"
    end
  end
end
