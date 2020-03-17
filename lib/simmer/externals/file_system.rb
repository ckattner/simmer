# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Simmer
  module Externals
    # Provides the shared basics of all file systems.
    class FileSystem
      SUFFIX = '-test'

      private_constant :SUFFIX

      def initialize(root)
        @root = root.to_s

        raise ArgumentError, "root: #{root} must end in #{SUFFIX}" unless root.end_with?(SUFFIX)
      end

      private

      attr_reader :root
    end
  end
end
