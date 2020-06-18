# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'configuration/callback_dsl'

module Simmer
  # Reads in the Simmer configuration file and options and provides it to the rest of the
  # Simmer implementation.
  class Configuration
    extend Forwardable

    # Configuration Keys
    AWS_FILE_SYSTEM_KEY   = :aws_file_system
    LOCAL_FILE_SYSTEM_KEY = :local_file_system
    MYSQL_DATABASE_KEY    = :mysql_database
    TIMEOUT_RETRY_KEY     = :timeout_failure_retry_count
    SPOON_CLIENT_KEY      = :spoon_client

    # Paths
    FILES    = 'files'
    FIXTURES = 'fixtures'
    RESULTS  = 'results'
    TESTS    = 'specs'

    private_constant :AWS_FILE_SYSTEM_KEY,
                     :MYSQL_DATABASE_KEY,
                     :SPOON_CLIENT_KEY,
                     :FILES,
                     :FIXTURES,
                     :TESTS

    attr_reader :config

    # :nodoc:
    def_delegators :callbacks, :run_single_test_with_callbacks, :run_suite_with_callbacks

    def initialize(config, simmer_dir, resolver: Objectable.resolver, callbacks: nil)
      @config      = config || {}
      @resolver    = resolver
      @simmer_dir  = simmer_dir
      @callbacks   = callbacks

      freeze
    end

    def mysql_database_config
      get(MYSQL_DATABASE_KEY) || {}
    end

    def aws_file_system_config
      get(AWS_FILE_SYSTEM_KEY) || {}
    end

    def local_file_system_config
      get(LOCAL_FILE_SYSTEM_KEY) || {}
    end

    def aws_file_system?
      config.key?(AWS_FILE_SYSTEM_KEY.to_s)
    end

    def local_file_system?
      config.key?(LOCAL_FILE_SYSTEM_KEY.to_s)
    end

    def timeout_failure_retry_count
      get(TIMEOUT_RETRY_KEY) || 0
    end

    def spoon_client_config
      get(SPOON_CLIENT_KEY) || {}
    end

    def tests_dir
      File.join(simmer_dir, TESTS)
    end

    def fixtures_dir
      File.join(simmer_dir, FIXTURES)
    end

    def files_dir
      File.join(simmer_dir, FILES)
    end

    def results_dir
      File.join(simmer_dir, RESULTS)
    end

    private

    attr_reader :callbacks,
                :resolver,
                :simmer_dir,
                :yaml_reader

    def get(key)
      resolver.get(config, key)
    end
  end
end
