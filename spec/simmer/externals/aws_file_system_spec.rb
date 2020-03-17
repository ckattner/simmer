# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'
require 'mocks/aws_s3_client'

describe Simmer::Externals::AwsFileSystem do
  let(:bucket_name)          { 'matt-test' }
  let(:encryption)           { 'AES256' }
  let(:files_dir)            { File.join('spec', 'fixtures') }
  let(:specification_path)   { File.join('specifications', 'load_noc_list.yaml') }
  let(:specification_config) { yaml_fixture(specification_path).merge(path: specification_path) }
  let(:specification)        { Simmer::Specification.make(specification_config) }
  let(:aws_s3_client_stub)   { AwsS3Client.new }

  subject { described_class.new(aws_s3_client_stub, bucket_name, encryption, files_dir) }

  describe 'initialization' do
    it "requires bucket ends in 'test'" do
      expect do
        described_class.new(aws_s3_client_stub, 'hehe', encryption, files_dir)
      end.to raise_error(ArgumentError)
    end
  end

  specify '#write transfers all files' do
    subject.write!(specification.stage.files)

    expected = {
      'input/noc_list.csv' => {
        body: "call_sign,first,last\niron_man,Tony,Stark\nhulk,Bruce,Banner\n"
      }
    }

    expect(aws_s3_client_stub.store).to eq(expected)
  end

  specify '#clean! deletes all files' do
    aws_s3_client_stub.put_object(
      body: 'Test File',
      bucket: bucket_name,
      key: 'test_key.txt',
      server_side_encryption: encryption
    )

    subject.clean!

    expected = {}

    expect(aws_s3_client_stub.store).to eq(expected)
  end
end
