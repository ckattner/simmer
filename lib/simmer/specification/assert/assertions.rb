# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'assertions/bad_output_assertion'
require_relative 'assertions/bad_table_assertion'
require_relative 'assertions/output'
require_relative 'assertions/table'

module Simmer
  class Specification
    class Assert
      # Factory class for assertions.
      class Assertions
        acts_as_hashable_factory

        register 'output', Output
        register 'table', Table
      end
    end
  end
end
