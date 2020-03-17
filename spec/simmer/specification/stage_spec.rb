# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe Simmer::Specification::Stage do
  let(:path) { File.join('specifications', 'load_noc_list.yaml') }

  let(:config) { yaml_fixture(path)['stage'] }

  describe 'initialization using acts_as_hashable' do
    subject { described_class.make(config) }

    it 'sets files' do
      expect(subject.files.length).to eq(1)
      expect(subject.files.first.src).to  eq('noc_list.csv')
      expect(subject.files.first.dest).to eq('input/noc_list.csv')
    end

    it 'sets fixtures' do
      expect(subject.fixtures.length).to eq(2)
      expect(subject.fixtures.first).to eq('iron_man')
      expect(subject.fixtures.last).to  eq('hulk')
    end
  end
end
