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

      attr_reader :errors, :id, :judge_result, :specification, :spoon_client_result

      def_delegators :specification, :name

      def initialize(
        id:,
        specification:,
        judge_result: nil,
        spoon_client_result: nil,
        errors: []
      )
        @id                  = id.to_s
        @judge_result        = judge_result
        @specification       = specification
        @spoon_client_result = spoon_client_result
        @errors              = Array(errors)

        freeze
      end

      def time_in_seconds
        spoon_client_result&.time_in_seconds || 0
      end

      def pass?
        [
          judge_result&.pass?,
          spoon_client_result&.pass?,
          errors.empty?,
        ].all?
      end
      alias passing? pass?

      def fail?
        !pass?
      end

      def timed_out?
        errors.any? { |e| e.is_a?(Timeout::Error) }
      end

      def to_h
        {
          'name' => specification.name,
          'id' => id,
          'path' => specification.path,
          'time_in_seconds' => time_in_seconds,
          'pass' => pass?,
          'spoon_client_result' => spoon_client_result.to_h,
          'judge_result' => judge_result.to_h,
          'errors' => errors.map(&:message),
        }
      end
    end
  end
end
