# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Simmer
  module Database
    # A fixture is a database record that can be inserted in the Stage phase of a specification
    # execution.
    class Fixture
      acts_as_hashable

      attr_reader :fields,
                  :name,
                  :table

      def initialize(fields: {}, name:, table:)
        @fields = fields || {}
        @name   = name.to_s
        @table  = table.to_s
      end

      def ==(other)
        other.instance_of?(self.class) &&
          fields == other.fields &&
          name == other.name &&
          table == other.table
      end
      alias eql? ==
    end
  end
end
