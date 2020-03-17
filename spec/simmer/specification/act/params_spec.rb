# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe Simmer::Specification::Act::Params do
  let(:spec_path)     { File.join('specifications', 'load_noc_list.yaml') }
  let(:params_config) { yaml_fixture(spec_path).dig('act', 'params') }

  let(:config) do
    {
      codes: {
        the_secret_one: '123ABC'
      }
    }
  end

  let(:files_path) { 'files_are_here' }

  subject { described_class.make(params_config) }

  it '#compile combines files and keys' do
    actual        = subject.compile(files_path, config)
    expected_path = File.expand_path(File.join(files_path, subject.files.values.first))
    expected      = {
      'input_file' => expected_path,
      'code' => 'The secret code is: 123ABC'
    }

    expect(actual).to eq(expected)
  end
end
