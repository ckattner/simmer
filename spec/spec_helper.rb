# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'ostruct'
require 'pry'

unless ENV['DISABLE_SIMPLECOV'] == 'true'
  require 'simplecov'
  require 'simplecov-console'

  SimpleCov.formatter = SimpleCov::Formatter::Console
  SimpleCov.start do
    add_filter %r{\A/spec/}
  end
end

RSpec.configure do |c|
  c.filter_run focus: true
  c.run_all_when_everything_filtered = true
end

require './lib/simmer'

def fixture_path(*filename)
  File.join('spec', 'fixtures', filename)
end

def fixture(*filename)
  File.read(fixture_path(*filename))
end

def yaml_fixture(*filename)
  YAML.safe_load(fixture(*filename), [], [], true)
end

def yaml_read(*filename)
  YAML.safe_load(File.read(File.join(*filename)), [], [], true)
end

def simmer_config
  yaml_read('spec', 'config', 'simmer.yaml')
end
