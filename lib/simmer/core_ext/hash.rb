# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Simmer
  module CoreExt
    # Monkey-patches for the core Hash class.  These will be manually mixed in separately.
    module Hash
      unless method_defined?(:symbolize_keys)
        def symbolize_keys
          map { |k, v| [k.to_sym, v] }.to_h
        end
      end
    end
  end
end
