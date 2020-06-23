# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'
require './spec/mocks/out'

describe Simmer do
  let(:src_config_path) { File.join('spec', 'config', 'simmer.yaml') }
  let(:config)          { yaml_read(src_config_path) }
  let(:spoon_path) { File.join('spec', 'mocks', 'spoon') }
  let(:spoon_args) { '' }
  let(:config_path) { stage_simmer_config(spoon_path, spoon_args) }

  def stage_simmer_config(spoon_dir, spoon_args, timeout_in_seconds = nil)
    dest_config_dir  = File.join('tmp')
    dest_config_path = File.join(dest_config_dir, 'simmer.yaml')

    FileUtils.rm(dest_config_path) if File.exist?(dest_config_path)
    FileUtils.mkdir_p(dest_config_dir)

    timeout = timeout_in_seconds || config.dig('spoon_client', 'timeout_in_seconds')

    new_config = config.merge(
      'spoon_client' => {
        'dir' => spoon_dir,
        'args' => spoon_args,
        'timeout_in_seconds' => timeout
      }
    )

    IO.write(dest_config_path, new_config.to_yaml)

    dest_config_path
  end

  context 'when externally mocking pdi and using local file system' do
    let(:spec_path)   { File.join('spec', 'fixtures', 'specifications', 'load_noc_list.yaml') }
    let(:simmer_dir)  { File.join('spec', 'simmer_spec') }
    let(:out)         { Out.new }

    context 'when pdi does not do anything but does not fail' do
      let(:spoon_args) { 0 }

      specify 'judge determines it does not pass' do
        results = described_class.run(
          spec_path,
          config_path: config_path,
          out: out,
          simmer_dir: simmer_dir
        )

        expect(results).not_to be_passing
      end
    end

    context 'when pdi fails' do
      let(:spoon_args) { 1 }

      it 'fails' do
        results = described_class.run(
          spec_path,
          config_path: config_path,
          out: out,
          simmer_dir: simmer_dir
        )

        expect(results).not_to be_passing
      end
    end

    context 'when pdi acts correctly' do
      let(:spoon_path) { File.join('spec', 'mocks', 'load_noc_list') }
      let(:spoon_args) { '' }

      # TODO: extract this to the top level, if they are all the same
      let(:results) do
        described_class.run(
          spec_path,
          config_path: config_path,
          out: out,
          simmer_dir: simmer_dir
        )
      end

      specify 'the judge determines it to pass' do
        expect(results).to be_passing
      end

      describe 'user defined lifecycle callbacks' do
        it 'calls them in the expected order' do
          found_order = []

          described_class.configure do |config|
            config.before(:suite) { found_order.push(:before_suite) }
            config.before(:each) { found_order.push(:before_each) }
            config.after(:each) { found_order.push(:after_each) }
            config.after(:suite) { found_order.push(:after_suite) }
          end

          expect(results).to be_passing
          expect(found_order).to eq %i[before_suite before_each after_each after_suite]
        end

        it 'passes the passing result to "after" callbacks' do
          after_each_result = nil
          after_suite_result = nil

          described_class.configure do |config|
            config.after(:each) { |result| after_each_result = result }
            config.after(:suite) { |result| after_suite_result = result }
          end

          expect(results).to be_passing
          expect(after_each_result).to be_passing
          expect(after_suite_result).to be_passing
        end
      end
    end

    context 'when pdi acts correctly but judge fails on output assert' do
      let(:spoon_path) { File.join('spec', 'mocks', 'load_noc_list_bad_output') }
      let(:spoon_args) { '' }
      let(:results) do
        described_class.run(
          spec_path,
          config_path: config_path,
          out: out,
          simmer_dir: simmer_dir
        )
      end

      specify 'fails' do
        expect(results).not_to be_passing
      end

      it 'passes the failing result to "after" callbacks' do
        after_each_result = nil
        after_suite_result = nil

        described_class.configure do |config|
          config.after(:each) { |result| after_each_result = result }
          config.after(:suite) { |result| after_suite_result = result }
        end

        expect(results).not_to be_passing
        expect(after_each_result).not_to be_passing
        expect(after_suite_result).not_to be_passing
      end
    end

    context 'when pdi times out' do
      let(:spoon_args) { [0, 10] }
      let(:config_path) { stage_simmer_config(spoon_path, spoon_args, 1) }

      let(:results) do
        described_class.run(
          spec_path,
          config_path: config_path,
          out: out,
          simmer_dir: simmer_dir
        )
      end

      it 'fails' do
        expect(results).not_to be_passing
      end

      it 'records the timeout error' do
        expect(results.runner_results.first.errors).to include(Timeout::Error)
      end

      specify 'after each callbacks get a failing result with the timeout error' do
        after_each_result = nil
        described_class.configure { |c| c.after(:each) { |result| after_each_result = result } }

        expect(results).not_to be_passing
        expect(after_each_result).not_to be_passing
        expect(after_each_result.errors).to include(Timeout::Error)
      end
    end
  end

  context 'when the fixtures are missing' do
    let(:spec_path)   { File.join('spec', 'fixtures', 'specifications', 'missing_fixtures.yaml') }
    let(:simmer_dir)  { File.join('spec', 'simmer_spec') }
    let(:out)         { Out.new }

    context 'when pdi does not do anything but does not fail' do
      let(:spoon_args) { 0 }

      it 'fails' do
        results = described_class.run(
          spec_path,
          config_path: config_path,
          out: out,
          simmer_dir: simmer_dir
        )

        expect(results).not_to be_passing
      end

      it 'records error' do
        results = described_class.run(
          spec_path,
          config_path: config_path,
          out: out,
          simmer_dir: simmer_dir
        )

        expect(results.runner_results.first.errors).to \
          include(Simmer::Database::FixtureSet::FixtureMissingError)
      end
    end
  end

  describe '.configuration' do
    it 'returns a Simmer::Configuration instance' do
      expect(described_class.configuration(config_path: config_path)).to be_a Simmer::Configuration
    end
  end
end
