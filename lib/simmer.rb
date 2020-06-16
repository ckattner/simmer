# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

# External libraries
require 'acts_as_hashable'
require 'aws-sdk-s3'
require 'benchmark'
require 'bigdecimal'
require 'fileutils'
require 'forwardable'
require 'mysql2'
require 'objectable'
require 'pdi'
require 'securerandom'
require 'set'
require 'stringento'
require 'yaml'

# Monkey-patching core libaries
require_relative 'simmer/core_ext/hash'
Hash.include Simmer::CoreExt::Hash

# Load up general use-case utils for entire library
require_relative 'simmer/util'

# Core code
require_relative 'simmer/configuration'
require_relative 'simmer/database'
require_relative 'simmer/externals'
require_relative 'simmer/runner'
require_relative 'simmer/specification'
require_relative 'simmer/suite'

# The main entry-point API for the library.
module Simmer
  DEFAULT_CONFIG_PATH = File.join('config', 'simmer.yaml').freeze
  DEFAULT_SIMMER_DIR  = 'simmer'

  class << self
    def run(
      path,
      config_path: DEFAULT_CONFIG_PATH,
      out: $stdout,
      simmer_dir: DEFAULT_SIMMER_DIR
    )
      configuration = make_configuration(config_path: config_path, simmer_dir: simmer_dir)
      specs         = make_specifications(path, configuration.tests_dir)
      out_router    = make_output_router(configuration, out)
      runner        = make_runner(configuration, out_router)
      suite         = make_suite(configuration, out, runner)

      suite.run(specs)
    end

    def make_configuration(config_path: DEFAULT_CONFIG_PATH, simmer_dir: DEFAULT_SIMMER_DIR)
      raw_config = yaml_reader.smash(config_path)
      Configuration.new(raw_config, simmer_dir, callbacks: callback_configuration)
    end

    def callback_configuration
      @callback_configuration ||= Configuration::CallbackDsl.new
    end

    def make_runner(configuration, out_router)
      database     = make_mysql_database(configuration)
      file_system  = make_file_system(configuration)
      fixture_set  = make_fixture_set(configuration)
      spoon_client = make_spoon_client(configuration)

      Runner.new(
        database: database,
        file_system: file_system,
        fixture_set: fixture_set,
        out: out_router,
        spoon_client: spoon_client
      )
    end

    def configure(&block)
      # TODO: support the arity 1 case
      # if block_given?
      #   if block.arity == 1
      #     yield self
      #   else
      #     instance_eval &block
      #   end
      # end
      callback_configuration.instance_eval(&block)
    end

    private

    def yaml_reader
      Util::YamlReader.new
    end

    def make_specifications(path, tests_dir)
      path = path.to_s.empty? ? tests_dir : path

      Util::YamlReader.new.read(path).map do |file|
        config = (file.data || {}).merge(path: file.path)

        Specification.make(config)
      end
    end

    def make_fixture_set(configuration)
      config = Util::YamlReader.new.smash(configuration.fixtures_dir)

      Database::FixtureSet.new(config)
    end

    def make_mysql_database(configuration)
      config         = configuration.mysql_database_config.symbolize_keys
      client         = Mysql2::Client.new(config)
      exclude_tables = config[:exclude_tables]

      Externals::MysqlDatabase.new(client, exclude_tables)
    end

    def make_file_system(configuration)
      if configuration.aws_file_system?
        make_aws_file_system(configuration)
      elsif configuration.local_file_system?
        make_local_file_system(configuration)
      else
        raise ArgumentError, 'cannot determine file system'
      end
    end

    def make_aws_file_system(configuration)
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

    def make_local_file_system(configuration)
      config = configuration.local_file_system_config.symbolize_keys

      Externals::LocalFileSystem.new(config[:dir], configuration.files_dir)
    end

    def make_spoon_client(configuration)
      config     = (configuration.spoon_client_config || {}).symbolize_keys
      spoon_args = config.slice(:args, :dir, :kitchen, :pan, :timeout_in_seconds)
      spoon      = Pdi::Spoon.new(spoon_args)

      Externals::SpoonClient.new(configuration.files_dir, spoon)
    end

    def make_suite(configuration, out, runner)
      Suite.new(
        config: configuration,
        out: out,
        results_dir: configuration.results_dir,
        runner: runner
      )
    end

    def make_output_router(configuration, console_out)
      pdi_out = Suite::PdiOutputWriter.new(configuration.results_dir)
      Simmer::Suite::OutputRouter.new(console_out, pdi_out)
    end
  end
end
