# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe Simmer::Configuration do
  let(:path)        { File.join('configuration.yaml') }
  let(:config)      { yaml_fixture(path) }
  let(:simmer_dir)  { 'simmer' }

  subject { described_class.new(config, simmer_dir) }

  context '#timeout_failure_retry_count' do
    it('defaults to 0 (no retry)') { expect(subject.timeout_failure_retry_count).to eq 0 }

    it 'returns the configured value' do
      subject = described_class.new({ timeout_failure_retry_count: 42 }, simmer_dir)
      expect(subject.timeout_failure_retry_count).to eq 42
    end
  end

  specify '#mysql_database_config resolves' do
    expect(subject.mysql_database_config).to eq('mysql_database_key' => 'mysql_database_value')
  end

  specify '#aws_file_system_config resolves' do
    expect(subject.aws_file_system_config).to eq('aws_file_system_key' => 'aws_file_system_value')
  end

  specify '#spoon_client_config resolves' do
    expect(subject.spoon_client_config).to eq('spoon_client_key' => 'spoon_client_value')
  end

  specify '#tests_dir resolves' do
    expect(subject.tests_dir).to eq(File.join(simmer_dir, 'specs'))
  end

  specify '#fixtures_dir resolves' do
    expect(subject.fixtures_dir).to eq(File.join(simmer_dir, 'fixtures'))
  end

  specify '#files_dir resolves' do
    expect(subject.files_dir).to eq(File.join(simmer_dir, 'files'))
  end

  specify '#results_dir resolves' do
    expect(subject.results_dir).to eq(File.join(simmer_dir, 'results'))
  end
end
