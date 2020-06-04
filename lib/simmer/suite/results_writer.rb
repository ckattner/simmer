# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Simmer
  class Suite
    # Understands how to write a SessionResult instance to disk.
    class ResulstWriter
      DATA_FILE = 'data.yaml'

      # Pass in dir here:
      def initialize(session_result)
        raise ArgumentError, 'session_result is required' unless session_result

        @session_result = session_result

        freeze
      end

      def write!(dir)
        dir = setup_directory(dir)

        IO.write(data_path(dir), session_result.to_h.to_yaml)

        self
      end

      private

      attr_reader :session_result

      def data_path(dir)
        File.join(dir, DATA_FILE)
      end

      def pdi_out_path(dir)
        File.join(dir, PDI_OUT_FILE)
      end

      def setup_directory(dir)
        File.expand_path(dir).tap do |expanded_dir|
          FileUtils.mkdir_p(expanded_dir)
        end
      end
    end
  end
end
