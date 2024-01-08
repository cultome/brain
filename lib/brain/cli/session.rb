class Brain::Cli::Session
  attr_reader :contexts

  def initialize(initial_ctx)
    @contexts = [initial_ctx]
  end

  def start!
    Readline.completion_append_character = ' '
    Readline.completer_word_break_characters = '&'
    Readline.completion_proc = proc { |s| completions_for s }

    @in_session = true

    while @in_session
      input = Readline.readline("#{contexts.first.prompt} > ", true)
      cmd = parse_command input

      if cmd.action == 'exit'
        @contexts.shift

        @in_session = false if @contexts.empty?
      else
        response = cmd.execute

        if response.nil?
          puts 'Unable to respond to that command'
          next
        end

        case response[:display]
        when :none
        when :text
          puts response[:value]
        when :list
          response[:value].each do |line|
            puts line
          end
        when :error
          puts "Error: #{response[:value]}"
        end
      end
    end

    puts 'Done!'
  end

  def completions_for(input)
    cmd = parse_command input

    cmd.completions
  end

  def parse_command(input)
    action, *params = input.split(' ').map(&:strip).delete_if(&:empty?)

    Brain::Cli::Command.new action, params || [], contexts.first
  end
end
