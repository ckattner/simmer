# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'resolver'

module Simmer
  module Util
    # Glues together Objectable and Stringento libraries to form a text template renderer.
    class Evaluator
      def initialize(resolver = Resolver.new)
        @resolver = resolver

        freeze
      end

      def evaluate(string, input = {})
        Stringento.evaluate(string, input, resolver: resolver)
      end

      private

      attr_reader :resolver
    end
  end
end
