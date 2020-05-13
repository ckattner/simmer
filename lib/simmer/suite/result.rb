# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Simmer
  class Suite
    # The return object for a Session#run call.
    class Result
      attr_reader :runner_results

      def initialize(runner_results = [])
        @runner_results = Array(runner_results)

        freeze
      end

      def pass?
        !fail?
      end
      alias passing? pass?

      def fail?
        runner_results.any?(&:fail?)
      end

      def time_in_seconds
        runner_results.inject(0.0) do |memo, runner_result|
          memo + runner_result.time_in_seconds
        end
      end

      def to_h
        {
          'pass' => pass?,
          'time_in_seconds' => time_in_seconds,
          'runner_results' => runner_results.map(&:to_h)
        }
      end
    end
  end
end
