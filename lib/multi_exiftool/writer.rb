# coding: utf-8
require_relative 'executable'

module MultiExiftool

  class Writer

    attr_accessor :values

    include Executable

    def command
      cmd = [exiftool_command]
      cmd << options_args
      cmd << values_args
      cmd << escaped_filenames
      cmd.flatten.join(' ')
    end

    alias write execute

    private

    def values_args
      raise MultiExiftool::Error.new('No values.') unless @values
      @values.map {|tag, val| "-#{tag}=#{escape(val.to_s)}"}
    end

    def parse_results
      @errors = @stderr.readlines
      @errors.empty?
    end

  end

end
