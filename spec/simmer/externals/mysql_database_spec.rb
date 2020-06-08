# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'
require 'db_helper'

describe Simmer::Externals::MysqlDatabase do
  let(:exclude_tables) { [] }
  let(:raw_fixtures)   { yaml_read('spec', 'fixtures', 'agent_fixtures.yaml') }
  let(:fixture_set)    { Simmer::Database::FixtureSet.new(raw_fixtures) }
  let(:spec_path)      { File.join('specifications', 'load_noc_list.yaml') }
  let(:spec_config)    { yaml_fixture(spec_path).merge(path: spec_path) }
  let(:specification)  { Simmer::Specification.make(spec_config) }

  subject { described_class.new(db_helper_client, exclude_tables) }

  before(:each) do
    db_helper_clean_schema
  end

  describe 'initialization' do
    it "requires database ends in 'test'" do
      expect do
        described_class.new(OpenStruct.new(query_options: { database: 'hehe' }))
      end.to raise_error(ArgumentError)
    end
  end

  describe '#seed!' do
    let(:fixtures) do
      specification.stage.fixtures.select.map { |f| fixture_set.get!(f) }
    end

    it 'adds records' do
      subject.seed!(fixtures)

      actual = db_helper_client.query('SELECT * FROM agents ORDER BY call_sign').to_a

      call_signs = actual.map { |r| r['call_sign'] }

      expect(call_signs).to eq(%w[hulk iron_man])
    end

    describe 'MySQL reserved words' do
      # Override:
      let(:spec_path) { File.join('specifications', 'handle_mysql_reserved_words.yaml') }

      it 'handles them' do
        subject.seed!(fixtures)

        actual = db_helper_client.query(
          'SELECT `column`, `count` FROM `table` ORDER BY `column`'
        ).to_a

        result = actual.map { |r| [r['column'], r['count']] }

        expected = [
          ['reserved1', 1],
          ['reserved2', 2],
        ]
        expect(result).to eq expected
      end
    end
  end

  specify '#clean! removes all records without worrying about foreign keys' do
    db_helper_client.query("INSERT INTO agents (id, call_sign) VALUES (1, 'thor')")
    db_helper_client.query("INSERT INTO notes (agent_id, note) VALUES (1, 'thor')")
    db_helper_client.query("INSERT INTO `table` (id, `column`, `count`) VALUES (1, 'foo', 3)")

    agent_count = db_helper_client.query('SELECT * FROM agents').to_a.length
    note_count = db_helper_client.query('SELECT * FROM notes').to_a.length
    reserved_word_count = db_helper_client.query('SELECT * FROM `table`').to_a.length

    expect(agent_count).to eq(1)
    expect(note_count).to  eq(1)
    expect(reserved_word_count).to eq(1)

    table_count = subject.clean!

    expect(table_count).to eq(3)
  end

  describe '#records' do
    before(:each) do
      db_helper_client.query("INSERT INTO agents (id, call_sign) VALUES (1, 'thor')")
      db_helper_client.query("INSERT INTO agents (id, call_sign) VALUES (2, 'black_widow')")
      db_helper_client.query("INSERT INTO `table` (id, `column`, `count`) VALUES (1, 'foo', 3)")
    end

    specify 'when fields is empty' do
      actual = subject.records(:agents)

      expected = [
        {
          'id' => 1,
          'call_sign' => 'thor',
          'first' => nil,
          'last' => nil
        },
        {
          'id' => 2,
          'call_sign' => 'black_widow',
          'first' => nil,
          'last' => nil
        },
      ]

      expect(actual).to eq(expected)
    end

    specify 'reads tables with reserved words as identifiers' do
      actual = subject.records(:table)

      expected = [
        {
          'id' => 1,
          'column' => 'foo',
          'count' => 3
        },
      ]

      expect(actual).to eq(expected)
    end
  end
end
