# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Simmer
  module Externals
    module SqlWriters
      # This class knows how to turn a fixture into sql.
      class SqlFixture
        extend Forwardable

        def_delegators :fixture,
                       :fields,
                       :table

        def initialize(client, fixture)
          raise ArgumentError, 'fixture is required' unless fixture

          @client  = client
          @fixture = fixture

          freeze
        end

        def to_sql
          sql_columns = fields.keys.map { |k| "`#{k}`" }.join(',')
          sql_values  = fields.values.map { |v| "'#{client.escape(v.to_s)}'" }.join(',')

          "INSERT INTO `#{table}` (#{sql_columns}) VALUES (#{sql_values})"
        end

        private

        attr_reader :client, :fixture
      end
    end
  end
end
