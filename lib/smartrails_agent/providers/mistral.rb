# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

module SmartRailsAgent
  module Providers
    class Mistral
      BASE_URL = 'https://api.mistral.ai/v1'
      DEFAULT_MODEL = 'mistral-tiny'

      def initialize(api_key: nil, model: DEFAULT_MODEL)
        @api_key = api_key || SmartRailsAgent.configuration.api_keys[:mistral] || ENV.fetch('MISTRAL_API_KEY', nil)
        @model = model

        raise Error, 'Mistral API key is required' unless @api_key
      end

      def chat(message, model: @model, temperature: 0.7, max_tokens: 1000, **options)
        payload = {
          model: model,
          messages: format_messages(message),
          temperature: temperature,
          max_tokens: max_tokens
        }.merge(options)

        response = make_request('/chat/completions', payload)
        parse_response(response)
      end

      def stream_chat(message, model: @model, temperature: 0.7, **options, &block)
        payload = {
          model: model,
          messages: format_messages(message),
          temperature: temperature,
          stream: true
        }.merge(options)

        make_streaming_request('/chat/completions', payload, &block)
      end

      def models
        response = make_request('/models')
        response.dig('data')&.map { |model| model['id'] } || []
      end

      private

      def format_messages(message)
        if message.is_a?(String)
          [{ role: 'user', content: message }]
        elsif message.is_a?(Array)
          message
        else
          raise ArgumentError, 'Message must be a String or Array of message objects'
        end
      end

      def make_request(endpoint, payload = nil)
        uri = URI("#{BASE_URL}#{endpoint}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.read_timeout = SmartRailsAgent.configuration.timeout

        request = if payload
                    Net::HTTP::Post.new(uri)
                  else
                    Net::HTTP::Get.new(uri)
                  end

        request['Authorization'] = "Bearer #{@api_key}"
        request['Content-Type'] = 'application/json'
        request.body = payload.to_json if payload

        response = http.request(request)
        handle_response(response)
      end

      def make_streaming_request(endpoint, payload, &block)
        raise Error, 'Block required for streaming' unless block_given?

        uri = URI("#{BASE_URL}#{endpoint}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.read_timeout = SmartRailsAgent.configuration.timeout

        request = Net::HTTP::Post.new(uri)
        request['Authorization'] = "Bearer #{@api_key}"
        request['Content-Type'] = 'application/json'
        request.body = payload.to_json

        http.request(request) do |response|
          handle_streaming_response(response, &block)
        end
      end

      def handle_response(response)
        case response.code.to_i
        when 200..299
          JSON.parse(response.body)
        when 401
          raise Error, 'Invalid Mistral API key'
        when 429
          raise Error, 'Rate limit exceeded'
        when 500..599
          raise Error, 'Mistral server error'
        else
          raise Error, "HTTP #{response.code}: #{response.body}"
        end
      end

      def handle_streaming_response(response, &block)
        response.read_body do |chunk|
          chunk.split("\n").each do |line|
            next unless line.start_with?('data: ')

            data = line[6..-1].strip
            next if data == '[DONE]'

            begin
              json_data = JSON.parse(data)
              content = json_data.dig('choices', 0, 'delta', 'content')
              block.call(content) if content
            rescue JSON::ParserError
              next
            end
          end
        end
      end

      def parse_response(response)
        content = response.dig('choices', 0, 'message', 'content')
        {
          content: content,
          model: response['model'],
          usage: response['usage']
        }
      end
    end
  end
end
