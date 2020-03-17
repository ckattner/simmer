# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe Simmer::CoreExt::Hash do
  specify 'Hash#symbolize_keys is implemented' do
    expect({ 'a' => 'b' }.symbolize_keys).to eq(a: 'b')
  end
end
