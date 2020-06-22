# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'
require './spec/mocks/out'

describe Simmer::Bootstrap do
  let(:simmer_dir)  { File.join('spec', 'simmer_spec') }
  let(:spec_path)   { File.join('spec', 'fixtures', 'specifications', 'load_noc_list.yaml') }
  let(:subject) do
    described_class.new(config_path: config_path, simmer_dir: simmer_dir, spec_path: spec_path)
  end

  before do
    # Required mocking so that '#run_suite' does not error out.
    allow(Mysql2::Client).to receive(:new)
    allow(Simmer::Externals::MysqlDatabase).to receive(:new).and_return(
      double(Simmer::Externals::MysqlDatabase)
    )
    allow(Pdi::Spoon).to receive(:new).and_return(double(Pdi::Spoon))
    suite_double = double(Simmer::Suite)
    allow(Simmer::Suite).to receive(:new).and_return(suite_double)
    allow(suite_double).to receive(:run)
  end

  describe 'when using the AWS file system' do
    let(:config_path) { File.join('spec', 'config', 'simmer_aws.yaml') }
    let(:aws_config) { yaml_read(config_path)['aws_file_system'].symbolize_keys }
    let(:s3_client_double) { double(Aws::S3::Client) }

    it 'creates a new S3 client and AwsFileSystem' do
      expect(Aws::S3::Client).to receive(:new).with(
        access_key_id: aws_config[:access_key_id],
        secret_access_key: aws_config[:secret_access_key],
        region: aws_config[:region]
      ).and_return(s3_client_double)

      expect(Simmer::Externals::AwsFileSystem).to receive(:new).with(
        s3_client_double,
        aws_config[:bucket],
        aws_config[:encryption],
        File.join(simmer_dir, 'files')
      )

      subject.run_suite
    end
  end

  describe 'when the file system is not specified' do
    let(:config_path) { File.join('spec', 'config', 'simmer_blank.yaml') }

    it 'raises an error' do
      expect { subject.run_suite }.to raise_error 'cannot determine file system'
    end
  end
end
