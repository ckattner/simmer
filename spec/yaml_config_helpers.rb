# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#
require 'yaml'

def yaml_read(*filename)
  YAML.safe_load(File.read(File.join(*filename)), [], [], true)
end

def simmer_config
  yaml_read('spec', 'config', 'simmer.yaml')
end
