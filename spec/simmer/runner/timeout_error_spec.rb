# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'
require './spec/mocks/out'

describe Simmer::Runner::TimeoutError do
  describe 'the message' do
    it 'is "a timeout ocurred" if there is no previous error' do
      subject = described_class.new
      expect(subject.message).to eq 'a timeout occurred'
    end

    it 'is the message of the error that caused it' do
      subject = nil

      begin
        begin
          raise 'custom message'
        rescue StandardError
          raise described_class
        end
      rescue described_class => e
        subject = e
      end

      expect(subject.message).to eq 'custom message'
    end
  end
end
