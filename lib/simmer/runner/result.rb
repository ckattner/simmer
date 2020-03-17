# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Simmer
  class Runner
    # Return object from a Runner#run call.
    class Result
      extend Forwardable

      attr_reader :id, :judge_result, :specification, :spoon_client_result

      def_delegators :spoon_client_result, :time_in_seconds

      def_delegators :specification, :name

      def initialize(id, judge_result, specification, spoon_client_result)
        @id                  = id.to_s
        @judge_result        = judge_result
        @specification       = specification
        @spoon_client_result = spoon_client_result

        freeze
      end

      def pass?
        judge_result&.pass? && spoon_client_result&.pass?
      end

      def fail?
        !pass?
      end

      def to_h
        {
          'name' => specification.name,
          'id' => id,
          'path' => specification.path,
          'time_in_seconds' => time_in_seconds,
          'pass' => pass?,
          'spoon_client_result' => spoon_client_result.to_h,
          'judge_result' => judge_result.to_h
        }
      end
    end
  end
end
