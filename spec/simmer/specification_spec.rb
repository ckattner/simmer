# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe Simmer::Specification do
  let(:path) { File.join('specifications', 'load_noc_list.yaml') }

  let(:config) { yaml_fixture(path).merge(path: path) }

  describe 'initialization using acts_as_hashable' do
    subject { described_class.make(config) }

    it 'sets name' do
      expect(subject.name).to eq('Declassify Users')
    end

    it 'sets path' do
      expect(subject.path).to eq(path)
    end
  end
end
