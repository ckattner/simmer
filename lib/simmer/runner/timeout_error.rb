# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Simmer
  class Runner
    # This error used when a specification times out. It is stored in
    # <tt>Simmer::Runner::Results#errors</tt> when a specification times out.
    class TimeoutError < RuntimeError
      def message
        cause ? cause.message : DEFAULT_MESSAGE
      end

      DEFAULT_MESSAGE = 'a timeout occurred'
      private_constant :DEFAULT_MESSAGE
    end
  end
end
