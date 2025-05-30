# frozen_string_literal: true

require 'ruby_llm/tool'

module Tools
  class ListFiles < RubyLLM::Tool
    description 'List files and directories at a given path. If no path is provided, lists files in the current directory.'
    param :path, desc: 'Optional relative path to list files from. Defaults to current directory if not provided.'

    def execute(path: '')
      Utilities::Logs.info("  [Agent] [List Files] - #{path}")
      Dir.glob(File.join(path, '*'))
         .map { |filename| File.directory?(filename) ? "#{filename}/" : filename }
    rescue StandardError => e
      { error: e.message }
    end
  end
end
