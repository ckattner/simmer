# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe Simmer::Util::RecordSet do
  let(:hash1) do
    {
      a: 'a',
      b: 'b'
    }
  end

  let(:string_hash1) do
    {
      'a' => 'a',
      'b' => 'b'
    }
  end

  let(:hash2) do
    {
      c: 'c',
      d: 'd'
    }
  end

  let(:string_hash2) do
    {
      'c' => 'c',
      'd' => 'd'
    }
  end

  let(:hash3) do
    {
      e: 'e',
      f: 'f'
    }
  end

  subject { described_class.new([hash1, hash2]) }

  describe 'equality' do
    specify 'hash order does not matter' do
      subject2 = described_class.new([hash2, hash1])

      expect(subject).to eq(subject2)
      expect(subject).to eql(subject2)
    end
  end

  specify '#keys includes all record keys' do
    expect(subject.keys).to eq(%w[a b c d])
  end

  specify '#to_h includes record hashes' do
    expect(subject.to_h).to eq('records' => [string_hash1, string_hash2])
  end

  describe 'initialization' do
    specify 'can accept a hash' do
      subject = described_class.new(hash1)

      expect(subject.records.length).to eq(1)
    end
  end

  specify '#& returns intersection of both record sets' do
    subject1 = described_class.new([hash1, hash2])
    subject2 = described_class.new([hash1, hash3])

    expected = described_class.new([hash1])
    actual   = subject1 & subject2

    expect(actual).to eq(expected)
  end
end
