# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe Simmer::Specification::Act do
  let(:path) { File.join('specifications', 'load_noc_list.yaml') }

  let(:config) { yaml_fixture(path)['act'] }

  describe 'initialization using acts_as_hashable' do
    subject { described_class.make(config) }

    it 'sets repository' do
      expect(subject.repository).to eq('top_secret')
    end

    it 'sets name' do
      expect(subject.name).to eq('load_noc_list')
    end

    it 'sets type' do
      expect(subject.type).to eq('transformation')
    end

    it 'sets params' do
      expect(subject.params.files).to eq('input_file' => 'noc_list.csv')
      expect(subject.params.keys).to  eq('code' => 'The secret code is: {codes.the_secret_one}')
    end
  end
end
