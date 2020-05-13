# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Simmer
  class Judge
    # The return object of a Judge#assert call.
    class Result
      attr_reader :bad_assertions

      def initialize(bad_assertions = [])
        @bad_assertions = bad_assertions

        freeze
      end

      def pass?
        bad_assertions.empty?
      end

      def to_h
        {
          'pass' => pass?,
          'bad_assertions' => bad_assertions.map(&:to_h)
        }
      end
    end
  end
end
