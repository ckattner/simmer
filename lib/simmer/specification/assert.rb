# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'assert/assertions'

module Simmer
  class Specification
    # Describes what should be expected after a Pdi::Spoon execution.
    class Assert
      acts_as_hashable

      attr_reader :assertions

      def initialize(assertions: [])
        @assertions = Assertions.array(assertions)

        freeze
      end
    end
  end
end
