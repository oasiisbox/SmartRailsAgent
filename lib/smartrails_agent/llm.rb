# frozen_string_literal: true

module SmartRailsAgent
  class LLM
    attr_reader :provider

    def initialize(provider:)
      @provider = provider
    end

    def chat(message, **options)
      validate_message(message)
      provider.chat(message, **options)
    end

    def stream_chat(message, ...)
      validate_message(message)
      raise Error, "Provider #{provider.class} does not support streaming" unless provider.respond_to?(:stream_chat)

      provider.stream_chat(message, ...)
    end

    def models
      provider.models if provider.respond_to?(:models)
    end

    def provider_info
      {
        name: provider.class.name.split('::').last.downcase,
        streaming_supported: provider.respond_to?(:stream_chat),
        models_supported: provider.respond_to?(:models)
      }
    end

    private

    def validate_message(message)
      raise ArgumentError, 'Message cannot be nil or empty' if message.nil? || message.strip.empty?
    end
  end
end
