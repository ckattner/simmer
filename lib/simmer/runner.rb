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

    def run(specification, config: {}, id: SecureRandom.uuid)
      print("Name: #{specification.name}")
      print("Path: #{specification.path}")

      clean_and_seed(specification)

      spoon_client_result = execute_spoon(specification, config)
      judge_result        = assert(specification, spoon_client_result)

      Result.new(
        id: id,
        judge_result: judge_result,
        specification: specification,
        spoon_client_result: spoon_client_result
      ).tap do |result|
        print_result(result)
      end
    rescue Database::FixtureSet::FixtureMissingError, Timeout::Error => e
      Result.new(
        id: id,
        specification: specification,
        errors: e.message
      ).tap do |result|
        print_result(result)
      end
    end

    private

    attr_reader :database, :file_system, :fixture_set, :judge, :out

    def print_result(result)
      msg = pass_message(result)
      print_waiting('Done', 'Final verdict')
      print(msg)
    end

    def clean_and_seed(specification)
      clean_db
      seed_db(specification)
      clean_file_system
      seed_file_system(specification)
    end

    def clean_db
      print_waiting('Stage', 'Cleaning database')
      count = database.clean!
      print("#{count} table(s) emptied")

      count
    end

    def seed_db(specification)
      print_waiting('Stage', 'Seeding database')

      fixtures = specification.stage.fixtures.map { |f| fixture_set.get!(f) }
      count    = database.seed!(fixtures)

      print("#{count} record(s) inserted")

      count
    rescue Database::FixtureSet::FixtureMissingError => e
      print('Missing Fixture(s)')
      raise e
    end

    def clean_file_system
      print_waiting('Stage', 'Cleaning File System')
      count = file_system.clean!
      print("#{count} file(s) deleted")

      count
    end

    def seed_file_system(specification)
      print_waiting('Stage', 'Seeding File System')
      count = file_system.write!(specification.stage.files)
      print("#{count} file(s) uploaded")

      count
    end

    def execute_spoon(specification, config)
      print_waiting('Act', 'Executing Spoon')

      spoon_client_result = spoon_client.run(specification, config)
      time_in_seconds     = spoon_client_result.time_in_seconds
      code                = spoon_client_result.execution_result.status.code

      msg = [
        pass_message(spoon_client_result),
        "(Exited with code #{code} after #{time_in_seconds} seconds)"
      ].join(' ')

      print(msg)

      spoon_client_result
    rescue Timeout::Error => e
      print('Timed out')
      raise e
    end

    def assert(specification, spoon_client_result)
      print_waiting('Assert', 'Checking results')

      if spoon_client_result.fail?
        print('Skipped')
        return nil
      end

      output       = spoon_client_result.execution_result.out
      judge_result = judge.assert(specification, output)
      msg          = pass_message(judge_result)

      print(msg)

      judge_result
    end

    def print(msg)
      out.puts(msg)
    end

    def print_waiting(stage, msg)
      max  = 25
      char = '.'
      msg  = "  > #{pad_right(stage, 6)} - #{pad_right(msg, max, char)}"

      out.print(msg)
    end

    def pad_right(msg, len, char = ' ')
      missing = len - msg.length

      "#{msg}#{char * missing}"
    end

    def pass_message(obj)
      obj.pass? ? 'Pass' : 'Fail'
    end
  end
end
