# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'bad_output_assertion'

module Simmer
  class Specification
    class Assert
      class Assertions
        # Describes an expected state of the output (log).
        class Output
          acts_as_hashable

          attr_reader :value

          def initialize(value:)
            @value = value.to_s

            freeze
          end

          def assert(_database, output)
            return nil if output.to_s.include?(value)

            BadOutputAssertion.new(value)
          end
        end
      end
    end
  end
end
