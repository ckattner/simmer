# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe Simmer::Suite::PdiOutputWriter do
  let(:results_dir) { Dir.mktmpdir('pdi_output_writer_spec') }
  let(:output_file) { File.open(File.join(results_dir, described_class::PDI_OUT_FILE), 'r') }
  let(:subject) { described_class.new(results_dir) }

  after do
    output_file.close
    subject.close
    FileUtils.remove_entry(results_dir)
  end

  it 'prints a header to identify a new spec' do
    subject.demarcate_spec('test_id', 'test name')
    subject.close

    expect(output_file.gets).to match(/----/)
    expect(output_file.gets).to eq "Name: test name\n"
    expect(output_file.gets).to eq "Runner ID: test_id\n"
    expect(output_file.gets).to match(/----/)
  end

  it 'writes arbitrary data immediately to the file' do
    subject.write('some important data')
    # Note that subject.close is not needed as the data is flushed to the file system immediately.

    expect(output_file.gets).to eq 'some important data'
  end

  specify 'when the spec is finished, a blank line is written' do
    subject.finish_spec
    subject.close

    expect(output_file.gets).to eq "\n"
  end
end
