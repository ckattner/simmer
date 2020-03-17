# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'record'

module Simmer
  module Util
    # A less-strict comparable collection of Record instances.
    # It does not depend on Record ordering.
    class RecordSet
      extend Forwardable

      def_delegators :records, :length

      attr_reader :records

      def initialize(records = [])
        @records = array(records).map { |record| Record.new(record) }.sort

        freeze
      end

      def ==(other)
        other.instance_of?(self.class) && records == other.records
      end
      alias eql? ==

      def to_h
        {
          'records' => records.map(&:to_h)
        }
      end

      def keys
        records.flat_map(&:keys)
      end

      def &(other)
        self.class.new(records & other.records)
      end

      private

      def array(val)
        if val.is_a?(Hash)
          [val]
        else
          Array(val)
        end
      end
    end
  end
end
