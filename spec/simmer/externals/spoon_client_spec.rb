# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'
require 'db_helper'

describe Simmer::Externals::SpoonClient do
  let(:files_dir)            { File.join('spec', 'fixtures') }
  let(:specification_path)   { File.join('specifications', 'load_noc_list.yaml') }
  let(:specification_config) { yaml_fixture(specification_path).merge(path: specification_path) }
  let(:specification)        { Simmer::Specification.make(specification_config) }

  let(:spoon) do
    Pdi::Spoon.new(
      dir: File.join('spec', 'mocks', 'spoon'),
      args: arg
    )
  end

  subject { described_class.new(files_dir, spoon) }

  context 'when PDI executes successfully' do
    let(:arg) { 0 }

    specify '#run returns code 0 from executor' do
      result = subject.run(specification, simmer_config)

      expect(result.execution_result.code).to eq(0)
    end
  end

  context 'when PDI executes un-successfully' do
    let(:arg) { 1 }

    specify '#run returns non-zero code from executor' do
      result = subject.run(specification, simmer_config)

      expect(result.execution_result.code).to eq(1)
    end
  end
end
