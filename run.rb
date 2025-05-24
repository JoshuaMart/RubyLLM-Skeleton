# frozen_string_literal: true

require 'optparse'
require 'yaml'
require_relative 'src/agent'

DEFAULT_CONFIG_FILE = 'config.yml'

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: run.rb [options]'

  opts.on('-c', '--config FILE', "Config file to use (default: #{DEFAULT_CONFIG_FILE})") do |v|
    options[:config_file] = v
  end

  opts.on('-m', '--model MODEL', 'Model to use (overrides config)') do |v|
    options[:model] = v
  end

  opts.on('-i', '--instructions INSTRUCTIONS', 'Instructions to provide to the agent') do |v|
    options[:instructions] = v
  end

  opts.on('--instructions-file FILE', 'File containing instructions') do |v|
    options[:instructions_file] = v
  end
end.parse!

def load_config(config_file)
  return {} unless File.exist?(config_file)

  YAML.safe_load_file(config_file, symbolize_names: true)
rescue StandardError => e
  puts "Error loading config file: #{e.message}"
  {}
end

def load_instructions(options)
  return options[:instructions] if options[:instructions]
  return unless options[:instructions_file]

  File.read(options[:instructions_file]) if File.exist?(options[:instructions_file])
end

# Load configuration
config_file = options[:config_file] || DEFAULT_CONFIG_FILE
config = load_config(config_file)

# Merge CLI options with config (priority CLI)
options = config.merge(options.compact)
options[:instructions] = load_instructions(options) || config[:instructions]
options[:api_key] ||= ENV.fetch('API_KEY', nil)

unless options[:api_key]
  raise 'No API Key provided. Please set the API_KEY in config.yml or API_KEY environment variable.'
end

puts '--- Instructions :'
puts options[:instructions]
puts "--------------\n\n"

Agent.new.run(options)
