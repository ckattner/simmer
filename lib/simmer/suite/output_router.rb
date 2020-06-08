# frozen_string_literal: true

module Simmer
  class Suite
    # Routes output either to the console or the <tt>PdiOutputWriter</tt>. It
    # also provides some methods to help format output.
    class OutputRouter
      extend Forwardable

      attr_reader :console, :pdi_out

      def_delegator :console, :puts, :console_puts
      def_delegators :pdi_out, :close, :finish_spec
      def_delegator :pdi_out, :write, :capture_spoon_output

      def initialize(console, pdi_out)
        @console = console || raise(ArgumentError, 'console is required')
        @pdi_out = pdi_out || raise(ArgumentError, 'pdi_out is required')

        freeze
      end

      def announce_start(id, specification)
        console_puts("Name: #{specification.name}")
        console_puts("Path: #{specification.path}")
        pdi_out.demarcate_spec(id, specification.name)
      end

      def result(result)
        console_puts(pass_message(result))
      end

      def final_verdict(result)
        msg = pass_message(result)
        waiting('Done', 'Final verdict')
        console_puts(msg)
      end

      def waiting(stage, msg)
        # This is not for debugging.
        # rubocop:disable Lint/Debugger
        console.print(
          "  > #{pad_right(stage, 6)} - #{pad_right(msg, WAITING_MAX_WIDTH, WAITING_PADDING_CHAR)}"
        )
        # rubocop:enable Lint/Debugger
      end

      def spoon_execution_detail_message(spoon_client_result)
        code = spoon_client_result.execution_result.status.code
        detail = "(Exited with code #{code} after #{spoon_client_result.time_in_seconds} seconds)"

        console_puts("#{pass_message(spoon_client_result)} #{detail}")
      end

      private

      WAITING_MAX_WIDTH = 25
      WAITING_PADDING_CHAR = '.'

      private_constant :WAITING_MAX_WIDTH, :WAITING_PADDING_CHAR

      def pad_right(msg, len, char = ' ')
        missing = len - msg.length

        "#{msg}#{char * missing}"
      end

      def pass_message(obj)
        obj.pass? ? 'Pass' : 'Fail'
      end
    end
  end
end
