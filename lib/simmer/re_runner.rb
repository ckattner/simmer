# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'judge'
require_relative 'runner/result'

module Simmer
  # :nodoc:
  # Wraps a <tt>Simmer::Runner</tt> and knows how to re-run tests based
  # on certain failure cases.
  class ReRunner < SimpleDelegator
    attr_reader :timeout_failure_retry_count

    def initialize(runner, out, timeout_failure_retry_count: 0)
      @timeout_failure_retry_count = timeout_failure_retry_count.to_i
      @out = out

      super(runner)
    end

    def run(*args)
      rerun_on_timeout(args, timeout_failure_retry_count)
    end

    private

    attr_reader :out

    def rerun_on_timeout(run_args, times)
      result = __getobj__.run(*run_args)

      if result.timed_out? && times.positive?
        out.puts('Retrying due to a timeout...')
        rerun_on_timeout(run_args, times - 1)
      else
        result
      end
    end
  end
end
