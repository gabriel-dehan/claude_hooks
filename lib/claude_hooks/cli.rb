# frozen_string_literal: true

require 'json'

module ClaudeHooks
  module CLI
    class << self
      # Run a hook script from the command line.
      # Reads JSON from STDIN, calls hook.call, and exits with the correct code.
      #
      # on_error controls what happens when the hook raises an unexpected exception:
      #   :allow (default) — exit 1, non-blocking; Claude continues as if the hook didn't run.
      #   :block           — exit 2, blocking; Claude stops and shows the error. Use this for
      #                      security/policy hooks where a crash should never silently pass through.
      #
      # Usage patterns:
      #
      # 1. Single hook class:
      #    ClaudeHooks::CLI.run_hook(MyHook)
      #    ClaudeHooks::CLI.run_hook(MyHook, on_error: :block)  # fail-closed
      #
      # 2. Multiple hooks with merging:
      #    ClaudeHooks::CLI.run_hook(on_error: :block) do |input_data|
      #      hook1 = Hook1.new(input_data)
      #      hook2 = Hook2.new(input_data)
      #      hook1.call
      #      hook2.call
      #      ClaudeHooks::Output::PreToolUse.merge(hook1.output, hook2.output).output_and_exit
      #    end
      def run_hook(hook_class = nil, on_error: :allow, &block)
        input_data = JSON.parse(STDIN.read)

        if block_given?
          yield(input_data)
        elsif hook_class
          hook = hook_class.new(input_data)
          hook.call
          hook.output_and_exit
        else
          raise ArgumentError, "Either provide a hook_class or a block"
        end

      rescue JSON::ParserError => e
        handle_run_error("JSON parsing error: #{e.message}", on_error)

      rescue StandardError => e
        handle_run_error("Hook execution error: #{e.message}", on_error, backtrace: e.backtrace)
      end

      # @deprecated Use {run_hook} instead.
      def entrypoint(hook_class = nil, on_error: :allow, &block)
        warn "[ClaudeHooks] CLI.entrypoint is deprecated — use CLI.run_hook instead."
        run_hook(hook_class, on_error: on_error, &block)
      end

      # Testing helpers — use these inside `if __FILE__ == $0` blocks, not in production.

      # Run a hook with input read from STDIN, with optional block to mutate input_data before running.
      def test_runner(hook_class, &block)
        input_data = read_stdin_input
        yield(input_data) if block_given?
        run_hook_with_data(hook_class, input_data)
      end

      # Run a hook with synthetic sample data (no STDIN needed).
      def run_with_sample_data(hook_class, sample_data = {}, &block)
        input_data = {
          'session_id' => 'test-session',
          'transcript_path' => '/tmp/test_transcript.md',
          'cwd' => Dir.pwd,
          'hook_event_name' => hook_class.hook_type
        }.merge(sample_data)

        yield(input_data) if block_given?
        run_hook_with_data(hook_class, input_data)
      end

      private

      # Runs a hook with already-parsed input_data. Returns the result without exiting.
      # Used internally by test_runner and run_with_sample_data.
      def run_hook_with_data(hook_class, input_data)
        hook = hook_class.new(input_data)
        result = hook.call
        puts JSON.generate(result) if result
        result
      rescue StandardError => e
        hook_name = hook_class.name || hook_class.to_s
        STDERR.puts "Error in #{hook_name} hook: #{e.message}"
        STDERR.puts e.backtrace.join("\n") if e.backtrace
        response = JSON.generate({
          continue: false,
          stopReason: "#{hook_name} execution error: #{e.message}",
          suppressOutput: false
        })
        puts response
        STDERR.puts response
        exit 1
      end

      def handle_run_error(message, on_error, backtrace: nil)
        if on_error == :block
          # Exit 2: Claude Code shows stderr to the model as plain text (never
          # parsed as JSON), so emit just the message and block.
          STDERR.puts message
          exit 2
        else
          # Exit 1: non-blocking. stderr's first line surfaces in the transcript.
          STDERR.puts backtrace.join("\n") if backtrace
          STDERR.puts JSON.generate({
            continue: false,
            stopReason: message,
            suppressOutput: false
          })
          exit 1
        end
      end

      def read_stdin_input
        stdin_content = STDIN.read.strip
        return {} if stdin_content.empty?
        JSON.parse(stdin_content)
      rescue JSON::ParserError => e
        raise "Invalid JSON input: #{e.message}"
      end
    end
  end
end
