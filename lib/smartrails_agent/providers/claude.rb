# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

module SmartRailsAgent
  module Providers
    class Claude
      BASE_URL = 'https://api.anthropic.com/v1'
      DEFAULT_MODEL = 'claude-3-haiku-20240307'
      API_VERSION = '2023-06-01'

      def initialize(api_key: nil, model: DEFAULT_MODEL)
        @api_key = api_key || SmartRailsAgent.configuration.api_keys[:claude] || ENV.fetch('ANTHROPIC_API_KEY', nil)
        @model = model

        raise Error, 'Claude API key is required' unless @api_key
      end

      def chat(message, model: @model, max_tokens: 1000, temperature: 0.7, **options)
        payload = {
          model: model,
          max_tokens: max_tokens,
          messages: format_messages(message),
          temperature: temperature
        }.merge(options)

        response = make_request('/messages', payload)
        parse_response(response)
      end

      def stream_chat(message, model: @model, max_tokens: 1000, temperature: 0.7, **options, &block)
        payload = {
          model: model,
          max_tokens: max_tokens,
          messages: format_messages(message),
          temperature: temperature,
          stream: true
        }.merge(options)

        make_streaming_request('/messages', payload, &block)
      end

      def models
        ['claude-3-opus-20240229', 'claude-3-sonnet-20240229', 'claude-3-haiku-20240307']
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

      def make_request(endpoint, payload)
        uri = URI("#{BASE_URL}#{endpoint}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.read_timeout = SmartRailsAgent.configuration.timeout

        request = Net::HTTP::Post.new(uri)
        request['x-api-key'] = @api_key
        request['anthropic-version'] = API_VERSION
        request['Content-Type'] = 'application/json'
        request.body = payload.to_json

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
        request['x-api-key'] = @api_key
        request['anthropic-version'] = API_VERSION
        request['Content-Type'] = 'application/json'
        request['Accept'] = 'text/event-stream'
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
          raise Error, 'Invalid Claude API key'
        when 429
          raise Error, 'Rate limit exceeded'
        when 500..599
          raise Error, 'Claude server error'
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
              if json_data['type'] == 'content_block_delta'
                content = json_data.dig('delta', 'text')
                block.call(content) if content
              end
            rescue JSON::ParserError
              next
            end
          end
        end
      end

      def parse_response(response)
        content = response.dig('content', 0, 'text')
        {
          content: content,
          model: response['model'],
          usage: response['usage'],
          stop_reason: response['stop_reason']
        }
      end
    end
  end
end
