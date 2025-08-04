# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

desc 'Run tests and linter'
task default: %i[spec rubocop]

desc 'Generate documentation'
task :doc do
  system('yard doc')
end

desc 'Clean generated files'
task :clean do
  system('rm -rf coverage/ doc/ pkg/ tmp/')
end

desc 'Run example script'
task :example do
  system('ruby examples/basic_usage.rb')
end

desc 'Install gem locally'
task :install_local do
  system('gem build smartrails_agent.gemspec && gem install smartrails_agent-*.gem && rm smartrails_agent-*.gem')
end
