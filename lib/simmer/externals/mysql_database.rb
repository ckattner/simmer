# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'sql_writers/sql_fixture'

module Simmer
  module Externals
    # Provides a wrapper around mysql2 for Simmer.
    class MysqlDatabase
      DATABASE_SUFFIX = '_test'

      def initialize(client, exclude_tables = [])
        @client = client

        assert_database_name(schema)

        exclude_tables = Array(exclude_tables).map(&:to_s)
        @table_names   = retrieve_table_names - exclude_tables

        freeze
      end

      def records(table, columns = [])
        query = "SELECT #{sql_select_params(columns)} FROM #{table}"

        client.query(query).to_a
      end

      def seed!(fixtures)
        sql_statements = seed_sql_statements(fixtures)

        shameless_execute(sql_statements)

        sql_statements.length
      end

      def clean!
        sql_statements = clean_sql_statements

        shameless_execute(sql_statements)

        sql_statements.length
      end

      private

      attr_reader :client, :fixture_set, :table_names

      def sql_select_params(columns)
        Array(columns).any? ? Array(columns).map { |c| client.escape(c) }.join(',') : '*'
      end

      def seed_sql_statements(fixtures)
        fixtures.map { |fixture| SqlWriters::SqlFixture.new(client, fixture).to_sql }
      end

      def clean_sql_statements
        table_names.map do |table_name|
          "TRUNCATE #{table_name}"
        end
      end

      def shameless_execute(sql_statements)
        execute(disable_checks_sql_statement)
        execute(sql_statements)
        execute(enable_checks_sql_statement)
      end

      def execute(*sql_statements)
        sql_statements.flatten.each do |sql_statement|
          client.query(sql_statement)
        end

        nil
      end

      def disable_checks_sql_statement
        'SET @@foreign_key_checks = 0'
      end

      def enable_checks_sql_statement
        'SET @@foreign_key_checks = 1'
      end

      def schema
        client.query_options[:database].to_s
      end

      def retrieve_table_names
        escaped_schema = client.escape(schema)

        sql = <<~SQL
          SELECT TABLE_NAME
          FROM INFORMATION_SCHEMA.TABLES
          WHERE TABLE_SCHEMA = '#{escaped_schema}'
            AND TABLE_TYPE = 'BASE TABLE'
        SQL

        client.query(sql).to_a.map { |v| v['TABLE_NAME'].to_s }
      end

      def assert_database_name(name)
        return if name.end_with?(DATABASE_SUFFIX)

        raise ArgumentError, "database (#{name}) must end in #{DATABASE_SUFFIX}"
      end
    end
  end
end
