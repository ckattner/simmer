# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Simmer
  module Util
    # A less strict comparable hash data structure.  It does not depend on key type, value type,
    # and key ordering.
    class Record
      extend Forwardable

      attr_reader :data

      def_delegators :data, :to_h, :hash

      def initialize(data = {})
        data = data.respond_to?(:to_h) ? data.to_h : data

        @data = sorted_string_hash(data)
      end

      def <=>(other)
        data <=> other.data
      end

      def ==(other)
        other.instance_of?(self.class) && data == other.data
      end
      alias eql? ==

      def keys
        data.map(&:first)
      end

      private

      def sorted_string_hash(hash)
        (hash || {}).map do |k, v|
          key   = k.to_s
          value = convert(v)

          [key, value]
        end.sort
      end

      def convert(value)
        value.is_a?(BigDecimal) ? value.to_s('F') : value.to_s
      end
    end
  end
end
