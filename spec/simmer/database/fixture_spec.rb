# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe Simmer::Database::Fixture do
  let(:config) do
    {
      fields: {
        first: 'Frank',
        last: 'Rizzo'
      },
      name: 'Some Fixture',
      table: 'users'
    }
  end

  describe 'initialization' do
    context 'when using acts_as_hashable' do
      subject { described_class.make(config) }

      it 'sets fields' do
        expect(subject.fields).to eq(config[:fields])
      end

      it 'sets name' do
        expect(subject.name).to eq(config[:name])
      end

      it 'sets table' do
        expect(subject.table).to eq(config[:table])
      end
    end
  end

  describe 'equality' do
    subject { described_class.new(config) }

    specify '#== compares all attributes' do
      subject2 = described_class.new(config)

      expect(subject).to eq(subject2)
    end

    specify '#eql? compares all attributes' do
      subject2 = described_class.new(config)

      expect(subject).to eql(subject2)
    end
  end
end
