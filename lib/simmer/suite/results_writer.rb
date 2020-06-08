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
      def initialize(session_result, results_dir)
        raise ArgumentError, 'session_result is required' unless session_result
        raise ArgumentError, 'results_directory is required' unless results_dir

        @session_result = session_result
        @results_directory = results_dir

        freeze
      end

      def write!
        dir = Util::FileSystem.setup_directory(results_directory)

        IO.write(data_path(dir), session_result.to_h.to_yaml)

        self
      end

      private

      attr_reader :results_directory, :session_result

      def data_path(dir)
        File.join(dir, DATA_FILE)
      end
    end
  end
end
