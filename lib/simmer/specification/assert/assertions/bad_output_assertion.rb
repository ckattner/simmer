# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Simmer
  class Specification
    class Assert
      class Assertions
        # Describes when the output does not meet expectations.
        class BadOutputAssertion
          attr_reader :expected_value

          def initialize(expected_value)
            @expected_value = expected_value

            freeze
          end

          def to_h
            {
              'type' => 'output',
              'expected_value' => expected_value
            }
          end
        end
      end
    end
  end
end
