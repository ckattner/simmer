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
    class Reporter
      DATA_FILE    = 'data.yaml'
      PDI_OUT_FILE = 'pdi_out.txt'
      PDI_ERR_FILE = 'pdi_err.txt'

      def initialize(session_result)
        raise ArgumentError, 'session_result is required' unless session_result

        @session_result = session_result

        freeze
      end

      def write!(dir)
        dir = setup_directory(dir)

        IO.write(data_path(dir), session_result.to_h.to_yaml)

        pdi_out_file = File.open(pdi_out_path(dir), 'w')
        pdi_err_file = File.open(pdi_err_path(dir), 'w')

        write_part(session_result.runner_results, pdi_out_file, pdi_err_file)

        pdi_out_file.close
        pdi_err_file.close

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

      def pdi_err_path(dir)
        File.join(dir, PDI_ERR_FILE)
      end

      def setup_directory(dir)
        File.expand_path(dir).tap do |expanded_dir|
          FileUtils.mkdir_p(expanded_dir)
        end
      end

      def write_part(runner_results, pdi_out_file, pdi_err_file)
        runner_results.each do |runner_result|
          name         = runner_result.name
          runner_id    = runner_result.id
          out_contents = runner_result.spoon_client_result.execution_result.out
          err_contents = runner_result.spoon_client_result.execution_result.err

          write_block(pdi_out_file, name, runner_id, out_contents)
          write_block(pdi_err_file, name, runner_id, err_contents)
        end

        nil
      end

      def write_block(file, name, runner_id, contents)
        hyphens = '-' * 80

        file.write("#{hyphens}\n")
        file.write("Name: #{name}\n")
        file.write("Runner ID: #{runner_id}\n")
        file.write("#{hyphens}\n")
        file.write("#{contents}\n")
        file.write("\n")

        nil
      end
    end
  end
end
