# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe Simmer::Runner::Result do
  let(:path)                 { File.join('specifications', 'load_noc_list.yaml') }
  let(:spec_config)          { yaml_fixture(path).merge(path: path) }
  let(:specification)        { Simmer::Specification.make(spec_config) }
  let(:id)                   { '123' }
  let(:passing_judge_result) { Simmer::Judge::Result.new }

  let(:passing_execution_result) do
    Pdi::Executor::Result.make(
      args: [],
      status: {
        code: 0,
        pid: 123
      }
    )
  end

  let(:passing_spoon_client_result) do
    Simmer::Externals::SpoonClient::Result.new(
      execution_result: passing_execution_result,
      time_in_seconds: 0
    )
  end

  describe '#pass?' do
    it 'is false if at least one error is present' do
      subject = described_class.new(
        id: id,
        specification: specification,
        errors: 'Some Error'
      )

      expect(subject.pass?).to be false
    end

    it 'is true if judge passes, spoon passes, and no errors are present' do
      subject = described_class.new(
        id: id,
        specification: specification,
        judge_result: passing_judge_result,
        spoon_client_result: passing_spoon_client_result
      )

      expect(subject.pass?).to be true
    end
  end
end
