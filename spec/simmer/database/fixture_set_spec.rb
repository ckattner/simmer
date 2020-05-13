# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe Simmer::Database::FixtureSet do
  let(:config) do
    {
      'Some Fixture' => {
        fields: {
          first: 'Frank',
          last: 'Rizzo'
        },
        table: 'users'
      },
      bozo: {
        fields: {
          first: 'Bozo',
          last: 'The Clown'
        },
        table: 'users'
      }
    }
  end

  subject { described_class.new(config) }

  describe '#get!' do
    context 'when name is a string' do
      it 'returns Fixture if name exists' do
        name = 'Some Fixture'

        expected = Simmer::Database::Fixture.make(config[name.to_s].merge(name: name))

        expect(subject.get!(name)).to eq(expected)

        name = 'bozo'

        expected = Simmer::Database::Fixture.make(config[name.to_sym].merge(name: name))

        expect(subject.get!(name)).to eq(expected)
      end

      it 'raises FixtureMissingError if name does not exist' do
        err = described_class::FixtureMissingError

        expect { subject.get!(:doesnt_exist) }.to raise_error(err)
      end
    end

    context 'when name is a symbol' do
      it 'returns Fixture if name exists' do
        name = :'Some Fixture'

        expected = Simmer::Database::Fixture.make(config[name.to_s].merge(name: name))

        expect(subject.get!(name)).to eq(expected)

        name = :bozo

        expected = Simmer::Database::Fixture.make(config[name.to_sym].merge(name: name))

        expect(subject.get!(name)).to eq(expected)
      end

      it 'raises FixtureMissingError if name does not exist' do
        err = described_class::FixtureMissingError

        expect { subject.get!(:doesnt_exist) }.to raise_error(err)
      end
    end
  end
end
