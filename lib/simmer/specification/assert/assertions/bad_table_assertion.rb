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
        # Describes when a database table does not meet expectations.
        class BadTableAssertion
          attr_reader :name, :expected_record_set, :actual_record_set

          def initialize(name, expected_record_set, actual_record_set)
            @name                = name
            @expected_record_set = expected_record_set
            @actual_record_set   = actual_record_set

            freeze
          end

          def to_h
            {
              'type' => 'table',
              'name' => name,
              'expected_record_set' => expected_record_set.to_h,
              'actual_record_set' => actual_record_set.to_h
            }
          end
        end
      end
    end
  end
end
