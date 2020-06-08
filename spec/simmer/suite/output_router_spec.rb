# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe Simmer::Suite::OutputRouter do
  let(:console_stub) { StringIO.new }
  let(:pdi_out_mock) { double(Simmer::Suite::PdiOutputWriter) }
  let(:subject) { described_class.new(console_stub, pdi_out_mock) }

  describe 'waiting' do
    it 'is formatted correctly with padding after the stage and message' do
      subject.waiting('Setup', 'Phase 1')
      expect(console_stub.string).to eq '  > Setup  - Phase 1..................'
    end
  end
end
