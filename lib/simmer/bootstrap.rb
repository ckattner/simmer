# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Simmer
  # :nodoc:
  # Responsible for creating core objects needed to run tests.
  class Bootstrap
    attr_reader :callback_configuration, :configuration, :console_out, :spec_path

    def initialize(
      config_path:,
      simmer_dir:,
      spec_path: nil,
      console_out: $stdout,
      callback_configuration: Configuration::CallbackDsl.new
    )
      @spec_path = spec_path.to_s
      raw_config = yaml_reader.smash(config_path)
      @configuration = Configuration.new(raw_config, simmer_dir, callbacks: callback_configuration)
      @console_out = console_out
      @callback_configuration = callback_configuration

      freeze
    end

    def run_suite
      suite.run(specs)
    end

    private

    def specs
      path = spec_path.empty? ? configuration.tests_dir : spec_path

      Util::YamlReader.new.read(path).map do |file|
        config = (file.data || {}).merge(path: file.path)

        Specification.make(config)
      end
    end

    def suite
      Suite.new(
        config: configuration,
        out: console_out,
        results_dir: configuration.results_dir,
        runner: runner
      )
    end

    def runner
      runner = Runner.new(
        database: mysql_database,
        file_system: file_system,
        fixture_set: fixture_set,
        out: output_router,
        spoon_client: spoon_client
      )

      ReRunner.new(
        runner,
        output_router,
        timeout_failure_retry_count: configuration.timeout_failure_retry_count
      )
    end

    def yaml_reader
      Util::YamlReader.new
    end

    def fixture_set
      config = Util::YamlReader.new.smash(configuration.fixtures_dir)

      Database::FixtureSet.new(config)
    end

    def mysql_database
      config         = configuration.mysql_database_config.symbolize_keys
      client         = Mysql2::Client.new(config)
      exclude_tables = config[:exclude_tables]

      Externals::MysqlDatabase.new(client, exclude_tables)
    end

    def file_system
      if configuration.aws_file_system?
        aws_file_system
      elsif configuration.local_file_system?
        local_file_system
      else
        raise ArgumentError, 'cannot determine file system'
      end
    end

    def aws_file_system
      config      = configuration.aws_file_system_config.symbolize_keys
      client_args = config.slice(:access_key_id, :secret_access_key, :region)
      client      = Aws::S3::Client.new(client_args)

      Externals::AwsFileSystem.new(
        client,
        config[:bucket],
        config[:encryption],
        configuration.files_dir
      )
    end

    def local_file_system
      config = configuration.local_file_system_config.symbolize_keys

      Externals::LocalFileSystem.new(config[:dir], configuration.files_dir)
    end

    def spoon_client
      config     = (configuration.spoon_client_config || {}).symbolize_keys
      spoon_args = config.slice(:args, :dir, :kitchen, :pan, :timeout_in_seconds)
      spoon      = Pdi::Spoon.new(spoon_args)

      Externals::SpoonClient.new(configuration.files_dir, spoon)
    end

    def output_router
      pdi_out = Suite::PdiOutputWriter.new(configuration.results_dir)
      Simmer::Suite::OutputRouter.new(console_out, pdi_out)
    end
  end
end
