# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

module SmartRailsAgent
  module Providers
    class Ollama
      DEFAULT_HOST = 'localhost'
      DEFAULT_PORT = 11_434
      DEFAULT_MODEL = 'llama2'

      def initialize(host: DEFAULT_HOST, port: DEFAULT_PORT, model: DEFAULT_MODEL)
        @host = host
        @port = port
        @model = model
        @base_url = "http://#{@host}:#{@port}"
      end

      def chat(message, model: @model, temperature: 0.7, **options)
        payload = {
          model: model,
          prompt: message.is_a?(String) ? message : format_conversation(message),
          stream: false,
          options: {
            temperature: temperature
          }.merge(options)
        }

        response = make_request('/api/generate', payload)
        parse_response(response)
      end

      def stream_chat(message, model: @model, temperature: 0.7, **options, &block)
        raise Error, 'Block required for streaming' unless block_given?

        payload = {
          model: model,
          prompt: message.is_a?(String) ? message : format_conversation(message),
          stream: true,
          options: {
            temperature: temperature
          }.merge(options)
        }

        make_streaming_request('/api/generate', payload, &block)
      end

      def models
        response = make_request('/api/tags')
        response.dig('models')&.map { |model| model['name'] } || []
      end

      def pull_model(model_name)
        payload = { name: model_name }
        make_request('/api/pull', payload)
      end

      def model_info(model_name)
        payload = { name: model_name }
        make_request('/api/show', payload)
      end

      private

      def format_conversation(messages)
        return messages if messages.is_a?(String)

        messages.map do |msg|
          role = msg[:role] || msg['role']
          content = msg[:content] || msg['content']
          "#{role}: #{content}"
        end.join("\n")
      end

      def make_request(endpoint, payload = nil)
        uri = URI("#{@base_url}#{endpoint}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.read_timeout = SmartRailsAgent.configuration.timeout

        request = if payload
                    Net::HTTP::Post.new(uri)
                  else
                    Net::HTTP::Get.new(uri)
                  end

        request['Content-Type'] = 'application/json'
        request.body = payload.to_json if payload

        response = http.request(request)
        handle_response(response)
      rescue Errno::ECONNREFUSED
        raise Error, "Cannot connect to Ollama at #{@base_url}. Is Ollama running?"
      end

      def make_streaming_request(endpoint, payload, &block)
        uri = URI("#{@base_url}#{endpoint}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.read_timeout = SmartRailsAgent.configuration.timeout

        request = Net::HTTP::Post.new(uri)
        request['Content-Type'] = 'application/json'
        request.body = payload.to_json

        http.request(request) do |response|
          handle_streaming_response(response, &block)
        end
      rescue Errno::ECONNREFUSED
        raise Error, "Cannot connect to Ollama at #{@base_url}. Is Ollama running?"
      end

      def handle_response(response)
        case response.code.to_i
        when 200..299
          JSON.parse(response.body)
        when 404
          raise Error, 'Model not found. You may need to pull it first with: ollama pull <model>'
        when 500..599
          raise Error, 'Ollama server error'
        else
          raise Error, "HTTP #{response.code}: #{response.body}"
        end
      end

      def handle_streaming_response(response, &block)
        response.read_body do |chunk|
          chunk.split("\n").each do |line|
            next if line.strip.empty?

            begin
              json_data = JSON.parse(line)
              content = json_data['response']
              block.call(content) if content && !content.empty?
            rescue JSON::ParserError
              next
            end
          end
        end
      end

      def parse_response(response)
        {
          content: response['response'],
          model: response['model'],
          context: response['context'],
          done: response['done']
        }
      end
    end
  end
end
