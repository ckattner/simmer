# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'bad_table_assertion'

module Simmer
  class Specification
    class Assert
      class Assertions
        # Describes an expected state of a database table.
        class Table
          acts_as_hashable

          module Logic
            EQUALS   = :equals
            INCLUDES = :includes
          end
          include Logic

          LOGIC_METHODS = {
            EQUALS => ->(actual_record_set, record_set) { actual_record_set == record_set },
            INCLUDES => lambda { |actual_record_set, record_set|
              (actual_record_set & record_set) == record_set
            }
          }.freeze

          attr_reader :logic, :name, :record_set

          def initialize(logic: EQUALS, name:, records: [])
            @logic      = Logic.const_get(logic.to_s.upcase.to_sym)
            @name       = name.to_s
            @record_set = Util::RecordSet.new(records)

            freeze
          end

          def assert(database, _output)
            keys                = record_set.keys
            actual_records      = database.records(name, keys)
            actual_record_set   = Util::RecordSet.new(actual_records)

            return nil if LOGIC_METHODS[logic].call(actual_record_set, record_set)

            BadTableAssertion.new(name, record_set, actual_record_set)
          end
        end
      end
    end
  end
end
