# SmartRailsAgent 🤖

[![Gem Version](https://badge.fury.io/rb/smartrails_agent.svg)](https://badge.fury.io/rb/smartrails_agent)
[![Ruby](https://img.shields.io/badge/ruby-3.0%2B-red.svg)](https://www.ruby-lang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Professional AI Integration for Ruby & Rails Applications**

SmartRailsAgent is a comprehensive Ruby gem designed to seamlessly integrate artificial intelligence capabilities into Ruby and Rails applications. Part of the **OASIISBOX SmartRails Suite**, it provides a unified interface for multiple AI providers with robust error handling, streaming support, and enterprise-grade reliability.

## 🚀 Features

- **Multi-Provider Support**: OpenAI, Anthropic Claude, Mistral AI, and Ollama
- **Streaming Capabilities**: Real-time response streaming where supported
- **Rails Integration**: Seamless integration with Rails applications
- **Configuration Management**: Flexible configuration via YAML, ENV, or code
- **Error Handling**: Comprehensive error handling and retry mechanisms
- **CLI Interface**: Command-line tool for quick AI interactions
- **Testing Support**: Built with testing in mind, mock-friendly architecture
- **Type Safety**: Comprehensive input validation and type checking

## 🔧 Installation

Add to your Gemfile:

```ruby
gem 'smartrails_agent'
```

Then execute:

```bash
bundle install
```

Or install directly:

```bash
gem install smartrails_agent
```

## ⚡ Quick Start

### Basic Usage

```ruby
require 'smartrails_agent'

# Configure your API keys
SmartRailsAgent.configure do |config|
  config.api_keys = {
    openai: ENV['OPENAI_API_KEY'],
    claude: ENV['ANTHROPIC_API_KEY']
  }
end

# Simple chat
response = SmartRailsAgent.chat("Explain Ruby blocks in simple terms")
puts response[:content]
```

### Rails Integration

```ruby
# config/initializers/smartrails_agent.rb
SmartRailsAgent.configure do |config|
  config.default_provider = :openai
  config.timeout = 30
  config.api_keys = {
    openai: Rails.application.credentials.openai_api_key,
    claude: Rails.application.credentials.anthropic_api_key
  }
end

# In your controllers/models
class ArticleController < ApplicationController
  def generate_summary
    @article = Article.find(params[:id])
    
    summary = SmartRailsAgent.chat(
      "Summarize this article: #{@article.content}",
      provider: :claude,
      max_tokens: 150
    )
    
    @article.update(ai_summary: summary[:content])
    redirect_to @article
  end
end
```

### Streaming Responses

```ruby
# Stream responses for real-time updates
SmartRailsAgent.chat("Write a story about Ruby programming") do |chunk|
  print chunk
  $stdout.flush
end
```

### Direct Provider Usage

```ruby
# Use specific providers directly
llm = SmartRailsAgent::LLM.new(
  provider: SmartRailsAgent::Providers::Ollama.new(model: 'llama2')
)

response = llm.chat("Hello, how are you?")
puts response[:content]
```

## 🔐 Configuration

### Environment Variables

```bash
# API Keys
export OPENAI_API_KEY="your-openai-key"
export ANTHROPIC_API_KEY="your-anthropic-key"
export MISTRAL_API_KEY="your-mistral-key"

# Ollama Configuration
export OLLAMA_HOST="localhost"
export OLLAMA_PORT="11434"
```

### YAML Configuration

```yaml
# config/smartrails_agent.yml
default_provider: openai
timeout: 30

api_keys:
  openai: "your-openai-api-key"
  claude: "your-anthropic-api-key"

providers:
  openai:
    model: "gpt-4"
    temperature: 0.7
  
  ollama:
    model: "llama2"
    host: "localhost"
    port: 11434
```

### Programmatic Configuration

```ruby
SmartRailsAgent.configure do |config|
  config.default_provider = :openai
  config.timeout = 60
  config.api_keys = {
    openai: "your-key-here",
    claude: "your-anthropic-key"
  }
end
```

## 🤖 Supported Providers

### OpenAI
- Models: GPT-4, GPT-3.5-turbo, and more
- Features: Chat, streaming, function calling
- Configuration: API key required

### Anthropic Claude
- Models: Claude-3 Opus, Sonnet, Haiku
- Features: Large context, safety-focused
- Configuration: API key required

### Mistral AI
- Models: Mistral-7B, Mixtral, and more
- Features: Efficient, multilingual
- Configuration: API key required

### Ollama (Local)
- Models: Llama2, CodeLlama, Mistral, and more
- Features: Local deployment, privacy-focused
- Configuration: Local Ollama server required

## 🛠️ CLI Usage

```bash
# Basic usage
smartrails-agent

# Show version
smartrails-agent --version

# Show help
smartrails-agent --help
```

## 🧪 Testing

```bash
# Run all tests
bundle exec rspec

# Run with coverage
bundle exec rspec --format documentation

# Run linting
bundle exec rubocop

# Run all checks
bundle exec rake
```

## 📚 SmartRails Suite Integration

SmartRailsAgent is designed to work seamlessly with other OASIISBOX SmartRails tools:

- **SmartRails Core**: Main auditing and analysis framework
- **SmartRails Web**: Web interface for reports and dashboards
- **SmartRails Agent**: This gem - AI integration capabilities

### Integration Example

```ruby
# Integration with SmartRails audit results
audit_results = SmartRails.audit(your_rails_app)

# Generate AI-powered improvement suggestions
suggestions = SmartRailsAgent.chat(
  "Based on these audit results, suggest improvements: #{audit_results.to_json}",
  provider: :claude,
  temperature: 0.3
)

puts suggestions[:content]
```

## 🔒 Security Considerations

- **API Key Safety**: Never commit API keys to version control
- **Rate Limiting**: Built-in respect for provider rate limits
- **Input Validation**: Comprehensive input sanitization
- **Error Handling**: Secure error messages without exposing internals
- **Audit Logging**: Optional request/response logging for compliance

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

```bash
git clone https://github.com/oasiisbox/SmartRailsAgent.git
cd SmartRailsAgent
bundle install
bundle exec rspec
```

### Code Standards

- Follow Ruby community standards
- Maintain test coverage above 90%
- Use RuboCop for code style
- Document public APIs with YARD

## 📈 Roadmap

- [ ] Additional AI providers (Google PaLM, Cohere)
- [ ] Built-in prompt templates and chains
- [ ] Advanced streaming with WebSockets
- [ ] Rails generators for AI-powered features
- [ ] Performance monitoring and analytics
- [ ] Enterprise SSO integration

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏢 About OASIISBOX

SmartRailsAgent is developed and maintained by **OASIISBOX**, creators of the SmartRails suite of developer tools. We're committed to making Ruby and Rails development more intelligent, efficient, and enjoyable.

### Contact & Support

- **GitHub**: [https://github.com/oasiisbox/SmartRails](https://github.com/oasiisbox/SmartRails)
- **Issues**: [Report bugs and feature requests](https://github.com/oasiisbox/SmartRailsAgent/issues)
- **Email**: [lanoix.pascal@gmail.com](mailto:lanoix.pascal@gmail.com)
- **Documentation**: [SmartRails Wiki](https://github.com/oasiisbox/SmartRails/wiki)

## 🙏 Acknowledgments

- The Ruby and Rails communities for inspiration
- All AI providers for making their platforms accessible
- Contributors and testers who help improve this gem

---

**Made with ❤️ by OASIISBOX - Empowering Ruby developers with AI**