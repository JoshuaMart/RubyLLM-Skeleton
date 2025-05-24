# frozen_string_literal: true

require 'ruby_llm'
Dir[File.join(__dir__, 'tools', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'utilities', '*.rb')].each { |file| require file }

# Agent class to interact with Claude using RubyLLM
class Agent
  # Initialize the agent with default empty tools configuration
  def initialize
    # Default configuration if none supplied
    @default_tools = %w[]
  end

  # Main entry point to run the agent with given options
  # @param options [Hash] Configuration options including :api_key, :model, :instructions, :tools
  def run(options = {})
    configure_ruby_llm(options[:api_key])
    setup_chat(options)
    start_chat_loop
  end

  private

  # Configure RubyLLM with the provided API key
  # @param api_key [String] The Anthropic API key for authentication
  def configure_ruby_llm(api_key)
    RubyLLM.configure do |config|
      if api_key.start_with?('sk-proj')
        config.openai_api_key = api_key
      elsif api_key.start_with?('sk-ant')
        config.anthropic_api_key = api_key
      end

      config.retry_interval = 50
    end

    RubyLLM.models.refresh!
  end

  # Set up the chat instance with model, instructions and tools
  # @param options [Hash] Configuration options containing model, instructions and tools
  def setup_chat(options)
    @chat = RubyLLM.chat(model: options[:model])
    @chat.with_instructions(options[:instructions]) if options[:instructions]

    tools = load_tools(options[:tools] || @default_tools)
    @chat.with_tools(*tools) if tools.any?
  end

  # Start the interactive chat loop with the user
  # Continuously prompts for user input and displays agent responses until 'exit' is entered
  def start_chat_loop
    puts "Chat with the agent. Type 'exit' to exit"
    loop do
      print '> '
      user_input = gets.chomp
      break if user_input == 'exit'

      response = @chat.ask user_input
      puts response.content
    rescue RubyLLM::RateLimitError
      Utilities::Logs.warn('  [Agent] [ERROR]      - Rate limit hit. Please wait a moment before trying again.')
    end
  end

  # Load and instantiate tools from their string names
  # @param tool_names [Array<String>] Array of tool class names to load
  # @return [Array<Class>] Array of loaded tool classes, excluding any that failed to load
  def load_tools(tool_names)
    tool_names.map do |tool_name|
      Tools.const_get(tool_name)
    rescue NameError => e
      puts "Warning: Tool '#{tool_name}' not found (#{e.message})"
      nil
    end.compact
  end
end
