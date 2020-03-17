# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Simmer
  module Util
    # Wraps up Objectable so it can be plugged into Stringento so we can use Objectable
    # as an object resolver.
    class Resolver
      attr_reader :objectable_resolver

      def initialize(objectable_resolver: Objectable.resolver)
        @objectable_resolver = objectable_resolver

        freeze
      end

      def resolve(value, input)
        objectable_resolver.get(input, value)
      end
    end
  end
end
