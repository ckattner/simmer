# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Simmer
  class Specification
    class Stage
      # Describes a file needing to be staged for a specification to execute properly.
      # It understands where the file exists in the local repository and where to transfer it
      # to.
      class InputFile
        acts_as_hashable

        attr_reader :dest, :src

        def initialize(dest:, src:)
          raise ArgumentError, 'dest is required'  if dest.to_s.empty?
          raise ArgumentError, 'src is required'   if src.to_s.empty?

          @dest = dest.to_s
          @src  = src.to_s

          freeze
        end
      end
    end
  end
end
