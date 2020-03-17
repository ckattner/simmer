# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'stage/input_file'

module Simmer
  class Specification
    # Describes the state necessary to exist before Spoon can be executed successfully.
    class Stage
      acts_as_hashable

      attr_reader :files, :fixtures

      def initialize(files: [], fixtures: [])
        @files    = InputFile.array(files)
        @fixtures = Array(fixtures).map(&:to_s)

        freeze
      end
    end
  end
end
