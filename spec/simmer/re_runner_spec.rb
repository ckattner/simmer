# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'
require './spec/mocks/out'

describe Simmer::ReRunner do
  let(:runner_double) { double(Simmer::Runner) }
  let(:passing_result) { Simmer::Runner::Result.new(id: :timeout, specification: :foo) }
  let(:out) do
    double(Simmer::Suite::OutputRouter).tap do |out|
      allow(out).to receive(:console_puts)
    end
  end
  let(:subject) { described_class.new(runner_double, out) }

  it 'delegates to the runner' do
    run_args = %i[foo bar]
    expect(runner_double).to receive(:run).with(run_args).and_return(passing_result)
    expect(runner_double).to receive(:complete)

    subject.run(run_args)
    subject.complete
  end

  it 'returns what the runner returns' do
    expect(runner_double).to receive(:run).and_return(passing_result)

    expect(subject.run).to eq passing_result
  end

  describe 'when a test fails due to a timeout' do
    let(:timeout_result) do
      errors = [Timeout::Error.new]
      Simmer::Runner::Result.new(id: :timeout, specification: :foo, errors: errors)
    end

    it 'only runs a test once when timeout_failure_retry_count = 0' do
      subject = described_class.new(runner_double, out, timeout_failure_retry_count: 0)
      expect(runner_double).to receive(:run).once.and_return(timeout_result)

      subject.run
    end

    it 'only runs the test three times when timeout_failure_retry_count = 2' do
      subject = described_class.new(runner_double, out, timeout_failure_retry_count: 2)
      expect(runner_double).to receive(:run).exactly(3).times.and_return(timeout_result)

      subject.run
    end

    it 'stops running the test as soon as it passes' do
      subject = described_class.new(runner_double, out, timeout_failure_retry_count: 2)
      expect(runner_double).to receive(:run).and_return(timeout_result)
      expect(runner_double).to receive(:run).and_return(passing_result)
      # Note that it is not retried a second time.

      subject.run
    end

    describe 'output' do
      it 'announces that a rerun is occurring due to a timeout' do
        subject = described_class.new(runner_double, out, timeout_failure_retry_count: 1)
        expect(runner_double).to receive(:run).and_return(timeout_result)
        expect(runner_double).to receive(:run).and_return(passing_result)

        expect(out).to receive(:console_puts).with('Retrying due to a timeout...').once

        subject.run
      end
    end
  end
end
