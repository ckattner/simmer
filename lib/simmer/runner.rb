# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'judge'
require_relative 'runner/result'

module Simmer
  # Runs a single specification.
  class Runner
    attr_reader :spoon_client

    def initialize(database:, file_system:, fixture_set:, out:, spoon_client:)
      @database     = database
      @file_system  = file_system
      @fixture_set  = fixture_set
      @judge        = Judge.new(database)
      @out          = out
      @spoon_client = spoon_client

      freeze
    end

    def run(specification, config:, id: SecureRandom.uuid)
      out.announce_start(id, specification)

      config.run_single_test_with_callbacks do
        clean_and_seed(specification)

        spoon_client_result = execute_spoon(specification, config)
        judge_result        = assert(specification, spoon_client_result)

        Result.new(
          id: id,
          judge_result: judge_result,
          specification: specification,
          spoon_client_result: spoon_client_result
        ).tap { |result| out.final_verdict(result) }
      rescue Database::FixtureSet::FixtureMissingError, Timeout::Error => e
        Result.new(id: id, specification: specification, errors: e.message)
              .tap { |result| out.final_verdict(result) }
      end
    end

    def complete
      out.close
    end

    private

    attr_reader :database, :file_system, :fixture_set, :judge, :out

    def clean_and_seed(specification)
      clean_db
      seed_db(specification)
      clean_file_system
      seed_file_system(specification)
    end

    def clean_db
      out.waiting('Stage', 'Cleaning database')
      count = database.clean!
      out.console_puts("#{count} table(s) emptied")

      count
    end

    def seed_db(specification)
      out.waiting('Stage', 'Seeding database')

      fixtures = specification.stage.fixtures.map { |f| fixture_set.get!(f) }
      count    = database.seed!(fixtures)

      out.console_puts("#{count} record(s) inserted")

      count
    rescue Database::FixtureSet::FixtureMissingError => e
      out.console_puts('Missing Fixture(s)')
      raise e
    end

    def clean_file_system
      out.waiting('Stage', 'Cleaning File System')
      count = file_system.clean!
      out.console_puts("#{count} file(s) deleted")

      count
    end

    def seed_file_system(specification)
      out.waiting('Stage', 'Seeding File System')
      count = file_system.write!(specification.stage.files)
      out.console_puts("#{count} file(s) uploaded")

      count
    end

    def execute_spoon(specification, config)
      out.waiting('Act', 'Executing Spoon')

      spoon_client_result = spoon_client.run(specification, config.config) do |output|
        out.capture_spoon_output(output)
      end

      out.finish_spec
      out.spoon_execution_detail_message(spoon_client_result)

      spoon_client_result
    rescue Timeout::Error => e
      out.console_puts('Timed out')
      raise e
    end

    def assert(specification, spoon_client_result)
      out.waiting('Assert', 'Checking results')

      if spoon_client_result.fail?
        out.console_puts('Skipped')
        return nil
      end

      output       = spoon_client_result.execution_result.out
      judge_result = judge.assert(specification, output)
      out.result(judge_result)

      judge_result
    end
  end
end
