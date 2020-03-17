# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

CLEAN_SQL_STATEMENTS = [
  'DELETE FROM `simmer_test`.`notes`',
  'DELETE FROM `simmer_test`.`agents`'
].freeze

def db_helper_config
  simmer_config['mysql_database']
end

def db_helper_client
  @db_helper_client ||= Mysql2::Client.new(db_helper_config)
end

def db_helper_clean_schema
  CLEAN_SQL_STATEMENTS.each { |sql| db_helper_client.query(sql) }
  nil
end
