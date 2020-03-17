# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe Simmer::Util::YamlReader do
  specify '#read reads file and returns parsed YAML' do
    path   = File.join('spec', 'fixtures', 'yaml_reader', 'foo.yaml')
    actual = subject.read(path)

    expected = [
      OpenStruct.new(
        path: File.expand_path(path),
        data: {
          'foo' => {
            'type' => 'foofy'
          }
        }
      )
    ]

    expect(actual).to eq(expected)
  end

  specify '#smash recursively combines all YAML in a directory' do
    path   = File.join('spec', 'fixtures', 'yaml_reader')
    actual = subject.smash(path)

    expected = {
      'bar' => {
        'type' => 'barby'
      },
      'baz' => {
        'type' => 'bazzy'
      },
      'foo' => {
        'type' => 'foofy'
      }
    }

    expect(actual).to eq(expected)
  end
end
