# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'suite/output_router'
require_relative 'suite/pdi_output_writer'
require_relative 'suite/results_writer'
require_relative 'suite/result'

module Simmer
  # Runs a collection of specifications and then writes down the results to disk.
  class Suite
    LINE_LENGTH = 80

    def initialize(
      config:,
      out:,
      resolver: Objectable.resolver,
      results_dir:,
      runner:
    )
      @config      = config
      @out         = out
      @resolver    = resolver
      @results_dir = results_dir
      @runner      = runner

      freeze
    end

    def run(specifications)
      config.run_suite_with_callbacks do
        runner_results = run_all_specs(specifications)
        runner.complete

        Result.new(runner_results).tap do |result|
          output_summary(result.pass?)

          ResulstWriter.new(result, results_dir).write!

          out.puts("Results can be viewed at #{results_dir}")
        end
      end
    end

    private

    attr_reader :config, :out, :results_dir, :resolver, :runner

    def run_all_specs(specifications)
      out.puts('Simmer suite started')

      count = specifications.length

      out.puts("Running #{count} specification(s)")
      print_line

      specifications.map.with_index(1) do |specification, index|
        run_single_spec(specification, index, count)
      end
    end

    def run_single_spec(specification, index, count)
      id = SecureRandom.uuid

      out.puts("Test #{index} of #{count}: #{id} (#{specification.act.type})")

      runner.run(specification, id: id, config: config).tap do
        print_line
      end
    end

    def print_line
      out.puts('-' * LINE_LENGTH)
    end

    def output_summary(passed)
      if passed
        out.puts('Suite ended successfully')
      else
        out.puts('Suite ended but was not successful')
      end
    end
  end
end
