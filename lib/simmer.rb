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

# Monkey-patching core libraries
require_relative 'simmer/core_ext/hash'
Hash.include Simmer::CoreExt::Hash

# Load up general use-case utils for entire library
require_relative 'simmer/util'

# Core code
require_relative 'simmer/bootstrap'
require_relative 'simmer/configuration'
require_relative 'simmer/database'
require_relative 'simmer/externals'
require_relative 'simmer/runner'
require_relative 'simmer/re_runner'
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
      Bootstrap.new(
        spec_path: path,
        config_path: config_path,
        simmer_dir: simmer_dir,
        callback_configuration: callback_configuration,
        console_out: out
      ).run_suite
    end

    def configuration(config_path: DEFAULT_CONFIG_PATH, simmer_dir: DEFAULT_SIMMER_DIR)
      Bootstrap.new(config_path: config_path, simmer_dir: simmer_dir).configuration
    end
    alias make_configuration configuration

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

    def callback_configuration
      @callback_configuration ||= Configuration::CallbackDsl.new
    end
  end
end
