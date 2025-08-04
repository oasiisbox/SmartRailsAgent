# frozen_string_literal: true

require_relative 'lib/smartrails_agent/version'

Gem::Specification.new do |spec|
  spec.name = 'smartrails_agent'
  spec.version = SmartRailsAgent::VERSION
  spec.authors = ['OASIISBOX.SmartRailsDEV']
  spec.email = ['lanoix.pascal@gmail.com']

  spec.summary = 'AI Integration Gem for Ruby and Rails - SmartRails Suite'
  spec.description = <<~DESC
    SmartRailsAgent is a professional Ruby gem for integrating AI capabilities (LLM, automation)#{' '}
    into Ruby and Rails applications. Part of the OASIISBOX SmartRails Suite, it provides#{' '}
    seamless integration with multiple AI providers including OpenAI, Ollama, Mistral, and Claude.
  DESC
  spec.homepage = 'https://github.com/oasiisbox/SmartRails'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/oasiisbox/SmartRailsAgent'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/oasiisbox/SmartRailsAgent/issues'
  spec.metadata['changelog_uri'] = 'https://github.com/oasiisbox/SmartRailsAgent/blob/main/CHANGELOG.md'
  spec.metadata['documentation_uri'] = 'https://github.com/oasiisbox/SmartRails/wiki'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = 'bin'
  spec.executables = ['smartrails-agent']
  spec.require_paths = ['lib']

  # Runtime dependencies
  spec.add_dependency 'json', '~> 2.6'

  # Development dependencies are specified in Gemfile
  spec.add_development_dependency 'bundler', '~> 2.0'
end
