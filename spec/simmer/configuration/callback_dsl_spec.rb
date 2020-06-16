# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe Simmer::Configuration::CallbackDsl do
  let(:subject) { described_class.new }

  describe 'running a single test with callbacks' do
    it 'runs and after callbacks in order of definition and returns the result of the block' do
      found_order = []

      subject.before { found_order.push(:first) }
      subject.before { found_order.push(:second) }

      subject.after { found_order.push(:third) }
      subject.after { found_order.push(:fourth) }

      expect(subject.run_single_test_with_callbacks { 42 }).to eq 42

      expect(found_order).to eq %i[first second third fourth]
    end

    it 'passes the return value of the test to after blocks' do
      found_return_value = nil
      subject.after { |return_value| found_return_value = return_value }

      subject.run_single_test_with_callbacks { :fake_test_result }

      expect(found_return_value).to eq :fake_test_result
    end

    it 'can be called with the ":each" level' do
      was_called = false
      subject.before(:each) { was_called = true }

      subject.run_single_test_with_callbacks {}

      expect(was_called).to eq true
    end
  end

  describe 'running a suite with callbacks' do
    it 'runs and after callbacks in order of definition and returns the result of the block' do
      found_order = []

      subject.before(:suite) { found_order.push(:first) }
      subject.before(:suite) { found_order.push(:second) }

      subject.after(:suite) { found_order.push(:third) }
      subject.after(:suite) { found_order.push(:fourth) }

      expect(subject.run_suite_with_callbacks { 42 }).to eq 42

      expect(found_order).to eq %i[first second third fourth]
    end

    it 'passes the return value of the suite to after blocks' do
      found_return_value = nil
      subject.after(:suite) { |return_value| found_return_value = return_value }

      subject.run_suite_with_callbacks { :fake_suite_result }

      expect(found_return_value).to eq :fake_suite_result
    end
  end

  describe 'error handling' do
    specify 'before raises and error when passed a bogus level' do
      expect { subject.before(:bogus) }.to raise_error ArgumentError
    end

    specify 'after raises and error when passed a bogus level' do
      expect { subject.after(:bogus) }.to raise_error ArgumentError
    end
  end
end
