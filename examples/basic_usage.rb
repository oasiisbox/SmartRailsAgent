#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/smartrails_agent'

# Configure SmartRailsAgent
SmartRailsAgent.configure do |config|
  config.default_provider = :openai
  config.timeout = 30
  config.api_keys = {
    openai: ENV.fetch('OPENAI_API_KEY', nil),
    mistral: ENV.fetch('MISTRAL_API_KEY', nil),
    claude: ENV.fetch('ANTHROPIC_API_KEY', nil)
  }
end

puts "SmartRailsAgent v#{SmartRailsAgent::VERSION} - Basic Usage Example"
puts 'Part of the OASIISBOX SmartRails Suite'
puts '=' * 50

# Example 1: Simple chat with default provider
begin
  puts "\n1. Simple Chat (OpenAI):"
  response = SmartRailsAgent.chat('Hello! What is Ruby?')
  puts "Response: #{response[:content]}"
rescue SmartRailsAgent::Error => e
  puts "Error: #{e.message}"
end

# Example 2: Chat with different provider
begin
  puts "\n2. Chat with Ollama:"
  response = SmartRailsAgent.chat('Explain Rails in one sentence', provider: :ollama)
  puts "Response: #{response[:content]}"
rescue SmartRailsAgent::Error => e
  puts "Error: #{e.message} (Ollama might not be running)"
end

# Example 3: Using LLM class directly
begin
  puts "\n3. Direct LLM Usage:"
  llm = SmartRailsAgent::LLM.new(provider: SmartRailsAgent::Providers::OpenAI.new)

  puts "Provider info: #{llm.provider_info}"

  response = llm.chat("What's the difference between a block and a proc in Ruby?")
  puts "Response: #{response[:content]}"
rescue SmartRailsAgent::Error => e
  puts "Error: #{e.message}"
end

# Example 4: Streaming chat (if supported)
begin
  puts "\n4. Streaming Chat:"
  print 'Streaming response: '

  SmartRailsAgent.chat('Count from 1 to 5 slowly', provider: :openai) do |chunk|
    print chunk
    $stdout.flush
  end
  puts
rescue SmartRailsAgent::Error => e
  puts "Error: #{e.message}"
end

puts "\nExample completed!"
puts 'For more information: https://github.com/oasiisbox/SmartRails'
