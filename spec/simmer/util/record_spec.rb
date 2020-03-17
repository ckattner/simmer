# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe Simmer::Util::Record do
  describe 'initialization' do
    let(:data) do
      {
        'a' => 'a'
      }
    end

    it 'accepts hash' do
      subject = described_class.new(data)

      expect(subject.to_h).to eq(data)
    end

    it 'accepts Record' do
      record  = Simmer::Util::Record.new(data)
      subject = described_class.new(record)

      expect(subject.to_h).to eq(data)
    end

    it 'accepts OpenStruct' do
      record  = OpenStruct.new(data)
      subject = described_class.new(record)

      expect(subject.to_h).to eq(data)
    end
  end

  describe 'equality' do
    context 'when key types do not equal' do
      let(:symbol_hash) do
        {
          '1': 1
        }
      end

      let(:string_hash) do
        {
          '1' => 1
        }
      end

      let(:numeric_hash) do
        {}.tap do |hash|
          hash[1] = 1
        end
      end

      it 'compares symbol to string keys' do
        record1 = described_class.new(symbol_hash)
        record2 = described_class.new(string_hash)

        expect(record1).to eq(record2)
        expect(record1).to eql(record2)
      end

      it 'compares symbol to number keys' do
        record1 = described_class.new(symbol_hash)
        record2 = described_class.new(numeric_hash)

        expect(record1).to eq(record2)
        expect(record1).to eql(record2)
      end

      it 'compares string to number keys' do
        record1 = described_class.new(string_hash)
        record2 = described_class.new(numeric_hash)

        expect(record1).to eq(record2)
        expect(record1).to eql(record2)
      end
    end

    context 'when value types do not equal' do
      let(:symbol_hash) do
        {
          a: :'1'
        }
      end

      let(:string_hash) do
        {
          a: '1'
        }
      end

      let(:numeric_hash) do
        {
          a: 1
        }
      end

      it 'compares symbol to string keys' do
        record1 = described_class.new(symbol_hash)
        record2 = described_class.new(string_hash)

        expect(record1).to eq(record2)
        expect(record1).to eql(record2)
      end

      it 'compares symbol to number keys' do
        record1 = described_class.new(symbol_hash)
        record2 = described_class.new(numeric_hash)

        expect(record1).to eq(record2)
        expect(record1).to eql(record2)
      end

      it 'compares string to number keys' do
        record1 = described_class.new(string_hash)
        record2 = described_class.new(numeric_hash)

        expect(record1).to eq(record2)
        expect(record1).to eql(record2)
      end
    end

    context 'when keys and values are not in same order and mixed type' do
      let(:alphabetical_hash) do
        {
          a: 'a',
          b: :b,
          'c': 'c'
        }
      end

      let(:reverse_alphabetical_hash) do
        {
          b: 'b',
          c: 'c',
          'a': :a
        }
      end

      it 'should ignore key ordering' do
        record1 = described_class.new(alphabetical_hash)
        record2 = described_class.new(reverse_alphabetical_hash)

        expect(record1).to eq(record2)
        expect(record1).to eql(record2)
      end
    end

    context 'when value(s) are of type BigDecimal' do
      let(:string_value) { '12.005' }

      let(:float_hash) do
        {
          a: string_value.to_f
        }
      end

      let(:big_decimal_hash) do
        {
          a: BigDecimal(string_value)
        }
      end

      let(:string_hash) do
        {
          a: string_value
        }
      end

      it 'compares floats with big decimals' do
        record1 = described_class.new(float_hash)
        record2 = described_class.new(big_decimal_hash)

        expect(record1).to eq(record2)
        expect(record1).to eql(record2)
      end

      it 'compares floats with strings' do
        record1 = described_class.new(float_hash)
        record2 = described_class.new(string_hash)

        expect(record1).to eq(record2)
        expect(record1).to eql(record2)
      end

      it 'compares big decimals with strings' do
        record1 = described_class.new(big_decimal_hash)
        record2 = described_class.new(string_hash)

        expect(record1).to eq(record2)
        expect(record1).to eql(record2)
      end
    end

    it 'should not equal if values are not equal' do
      record1 = described_class.new(a: 'a')
      record2 = described_class.new(a: 'b')

      expect(record1).not_to eq(record2)
      expect(record1).not_to eql(record2)
    end

    it 'should not equal if keys are not equal' do
      record1 = described_class.new(a: 'a')
      record2 = described_class.new(b: 'a')

      expect(record1).not_to eq(record2)
      expect(record1).not_to eql(record2)
    end
  end
end
