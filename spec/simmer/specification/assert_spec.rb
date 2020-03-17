# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe Simmer::Specification::Assert do
  let(:path) { File.join('specifications', 'load_noc_list.yaml') }

  let(:config) { yaml_fixture(path)['assert'] }

  describe 'initialization using acts_as_hashable' do
    subject { described_class.make(config) }

    it 'sets assertions' do
      expect(subject.assertions.length).to                  eq(3)
      expect(subject.assertions.first.name).to              eq('agents')
      expect(subject.assertions.first.record_set.length).to eq(2)
      expect(subject.assertions[1].name).to                 eq('agents')
      expect(subject.assertions[1].record_set.length).to    eq(1)
      expect(subject.assertions.last.value).to              eq('output to stdout')
    end
  end
end
