# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Simmer
  module Externals
    class SpoonClient
      # The return object from a SpoonClient#run call.
      class Result
        attr_reader :message, :execution_result, :time_in_seconds

        def initialize(message: '', execution_result:, time_in_seconds:)
          @message          = message
          @execution_result = execution_result
          @time_in_seconds  = (time_in_seconds || 0).round(2)

          freeze
        end

        def pass?
          execution_result.code.zero?
        end

        def fail?
          !pass?
        end

        def to_h
          {
            'pass' => pass?,
            'message' => message,
            'execution_result' => {
              'args' => execution_result.args,
              'code' => execution_result.code,
              'pid' => execution_result.pid
            },
            'time_in_seconds' => time_in_seconds
          }
        end
      end
    end
  end
end
