# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Simmer
  class Suite
    # Captures PDI output from multiple specifications to a single file.
    class PdiOutputWriter
      PDI_OUT_FILE = 'pdi_out.txt'

      attr_reader :results_dir

      def initialize(results_dir)
        raise ArgumentError, 'results_dir is required' unless results_dir

        @out = File.new(File.join(results_dir, PDI_OUT_FILE), 'w')

        freeze
      end

      def demarcate_spec(runner_id, spec_name)
        out.puts(LINE_OF_HYPHENS)
        out.puts("Name: #{spec_name}")
        out.puts("Runner ID: #{runner_id}")
        out.puts(LINE_OF_HYPHENS)
      end

      def write(contents)
        bytes_written = out.write(contents)
        out.flush
        bytes_written
      end

      def finish_spec
        out.puts
      end

      # TODO: call this somewhere
      def close
        out.close
      end

      private

      attr_reader :out

      LINE_OF_HYPHENS = ('-' * 80).freeze
      private_constant :LINE_OF_HYPHENS
    end
  end
end
